//
//  DownloadAircraftDataOp.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 11/3/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import Foundation

class DownloadThumbnailOp: Operation {
    private lazy var sharedSession = {
        NSURLSession.sharedSession()
    }()

    private var aircraft: Aircraft
    private var thumbnailURL: String
    private var context: NSManagedObjectContext
    private var task: NSURLSessionTask?
    
    init(aircraft: Aircraft, url: String, context: NSManagedObjectContext) {
        self.aircraft = aircraft
        self.thumbnailURL = url
        self.context = context
    }
    
    override func execute() {
        if cancelled {
            finish()
        }
        
        let request = NSURLRequest(URL: NSURL(string: thumbnailURL)!)
        task = sharedSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            defer {
                print("Finishing DownloadThumbnailOp task")
                self.finish()
            }

            if let error = error {
                print("Error downloading thumbnail, error:\(error)")
                return
            }
            
            guard let data = data else {
                print("DownloadThumbnailOp: Unable to get data")
                return
            }

            self.context.performBlock({ () -> Void in
                self.aircraft.thumbnail = data
            })
        }
        
        task!.resume()
    }
}

class DownloadDataOp: Operation {
    private enum DownlaodDataOpError: ErrorType {
        case InvalidData
    }
    
    private lazy var sharedSession = {
        NSURLSession.sharedSession()
    }()

    private var sharedContext: NSManagedObjectContext

    private let internalQueue = NSOperationQueue()

    private var aircraft: Aircraft
    
    init(aircraft: Aircraft, context: NSManagedObjectContext) {
        self.aircraft = aircraft
        self.sharedContext = context
    }
    
    override func execute() {
        if cancelled {
            finish()
        }
        
        let dataURI = getDataURIFromResource(aircraft.uri)

        let task = sharedSession.dataTaskWithURL(dataURI, completionHandler: { (data, response, error) -> Void in
            defer {
                print("Finishing DownloadDataOp task")
//                self.finish()
            }
            
            if let error = error {
                print("Unable to download data from\(self.aircraft.uri), error: \(error)")
                return
            }
            
            guard let data = data else {
                print("Unable to get data")
                return
            }
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject],
                    let aircraftData = jsonResult[self.aircraft.uri] as? [String: AnyObject] {
                        try self.getAircraftData(self.aircraft, aircraftData: aircraftData)
                        try self.sharedContext.save()
                }
            } catch {
                print("Caught error creating JSON, error=\(error)")
                return
            }
        })
        
        task.resume()
    }
    
    /// Given a DBPedia resource URL, create the corresponding data URL that can be used to return
    /// the resource data as JSON.
    private func getDataURIFromResource(resourceURI: String) -> NSURL {
        let resourceName = NSURL(string: resourceURI)!.lastPathComponent!
        
        let fullURL = DBDownloader.DBPediaAPIConstants.DATA_URL + "/\(resourceName).json"
        
        return NSURL(string: fullURL)!
    }

    private func getAircraftData(aircraft: Aircraft, aircraftData: [String: AnyObject]) throws -> Aircraft? {
        if let manufacturer = aircraftData[DBDownloader.DBPediaAPIConstants.MANUFACTURER_KEY] as? [[String: String]] {
            let manufacturerDict = manufacturer[0]
            if manufacturerDict["type"] == "uri" {
                let labels = aircraftData["http://www.w3.org/2000/01/rdf-schema#label"] as! [[String: String]]
                for label in labels {
                    if label["lang"] == "en" {
                        aircraft.manufacturer = label["value"]!
                        break
                    }
                }
            } else if manufacturerDict["type"] == "literal" {
                aircraft.manufacturer = manufacturerDict["value"] as String!
            } else {
                throw DownlaodDataOpError.InvalidData
            }
        } else {
            aircraft.manufacturer = "Unknown"
        }
        
        if let crew = aircraftData[DBDownloader.DBPediaAPIConstants.CREW_KEY] as? [AnyObject],
            let crewDict = crew[0] as? [String: AnyObject] {
                
            if let value = crewDict["value"] as? Int {
                aircraft.crew = String(value)
            } else if let value = crewDict["value"] as? String {
                aircraft.crew = value
            } else {
                aircraft.crew = "Unknown"
            }
        } else {
            aircraft.crew = "Unknown"
        }
        
        if let produced = aircraftData[DBDownloader.DBPediaAPIConstants.NUMBER_BUILT_KEY] as? [AnyObject],
            let producedDict = produced[0] as? [String: AnyObject] {
            if let value = producedDict["value"] as? Int {
                aircraft.numberBuilt = String(value)
            } else if let value = producedDict["value"] as? String {
                aircraft.numberBuilt = value
            } else {
                aircraft.numberBuilt = "Unknown"
            }
        } else {
            aircraft.crew = "Unknown"
        }
        
        if let introduced = aircraftData[DBDownloader.DBPediaAPIConstants.INTRODUCTION_KEY] as? [AnyObject],
            let introducedDict = introduced[0] as? [String: AnyObject],
            let value = introducedDict["value"] as? String {
                aircraft.yearIntroduced = value
        }
        
        if let origin = aircraftData[DBDownloader.DBPediaAPIConstants.NATIONAL_ORIGIN_KEY] as? [AnyObject],
            let originDict = origin[0] as? [String: AnyObject],
            let value = originDict["value"] as? String {
                aircraft.country = value
        }
        
        if let thumbnailData = aircraftData[DBDownloader.DBPediaAPIConstants.THUMBNAIL_KEY] as? [[String: AnyObject]],
            let imageURL = thumbnailData[0]["value"] as? String {
                print("imageURL=\(imageURL)")

                let thumbnailOp = DownloadThumbnailOp(aircraft: aircraft, url: imageURL, context: sharedContext)
                thumbnailOp.completionBlock = {
                    print("Finished DownloadThumbnailOp")
                    self.finish()
                }
                
                self.addDependency(thumbnailOp)
                internalQueue.addOperation(thumbnailOp)
        }
        
        return aircraft
    }
}

class DownloadAircraftDetailsOp: Operation {
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }

    private var internalQueue = NSOperationQueue()
    
    override func execute() {
        if cancelled {
            finish()
        }
        
        let aircraftResults: [Aircraft]
        let fetchRequest = NSFetchRequest(entityName: "Aircraft")
        do {
            aircraftResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Aircraft] ?? []
        } catch {
            aircraftResults = []
        }
        
        for aircraft in aircraftResults {
            if cancelled {
                finish()
                break
            }
            
            let dataOp = DownloadDataOp(aircraft: aircraft, context: sharedContext)
            dataOp.completionBlock = {
                print("DownloadDataOp completed for \(aircraft.name)")
                self.sharedContext.performBlock({ () -> Void in
                    try! self.sharedContext.save()
                })
            }
            
            self.addDependency(dataOp)
            internalQueue.addOperation(dataOp)
        }
        
//        finish()
    }
}
