//
//  DBDownloader.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/1/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import Foundation
import CoreData

/// A struct that represents the results of a DBPedia lookup operation
struct DBPediaLookupResult {
    var resourceURI: String
    var label: String
    var abstract: String
    var categories: [String: AnyObject]
}

class DBDownloader {
    private let sharedSession = NSURLSession.sharedSession()
    private let operationQueue = NSOperationQueue()

    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }

    private static let kDBDownloaderErrorDomain = "com.notlus.dbdownloader"
    
    /// Error definitions
    enum DBDownloadError : ErrorType {
        case NotFound
        case Unexpected
    }
    
    struct LookupAPIConstants {
        static let BASE_URL = "http://lookup.dbpedia.org/api/search/KeywordSearch"
        static let MAXHITS = "MaxHits"
        static let FORMAT = "json"
        static let QUERY_CLASS = "QueryClass"
    }
    
    struct DataConstants {
        static let RESULTS_KEY = "results"
        
        /// The key for the array of ontologies
        static let CLASSES_KEY = "classes"
        
        /// The key for the array of resource/Category URLs
        static let CATEGORIES_KEY = "categories"
        
        /// The DBPedia resource URL
        static let RESOURCE_URI_KEY = "url"
        
        /// The text description of the resource
        static let DESCRIPTION_KEY = "description"
        
        /// The DBPedia ontology URL
        static let AIRCRAFT_CLASS = "http://dbpedia.org/ontology/Aircraft"
    }

    struct DBPediaAPIConstants {
        static let DATA_URL = "http://dbpedia.org/data"
        static let THUMBNAIL_KEY = "http://dbpedia.org/ontology/thumbnail"
        static let THUMBNAIL_URL_KEY = "value"
        static let CREW_KEY = "http://dbpedia.org/property/crew"
        static let MANUFACTURER_KEY = "http://dbpedia.org/property/manufacturer"
        static let INTRODUCTION_KEY = "http://dbpedia.org/property/introduction"
        static let NUMBER_BUILT_KEY = "http://dbpedia.org/property/numberBuilt"
        static let NATIONAL_ORIGIN_KEY = "http://dbpedia.org/property/nationalOrigin"
    }
    
    /// Perform a search using the DBPedia Lookup API. On success returns an array of `AnyObject`
    /// values that represent the deserialized JSON data.
    func performSearch(keyword: String, completion: ([AnyObject]?, error: NSError?) -> Void) {
        
        let methodArguments = [
            LookupAPIConstants.QUERY_CLASS: "thing",
            "QueryString": keyword,
            LookupAPIConstants.MAXHITS: "1000"
        ]
        
        let url = createURL(LookupAPIConstants.BASE_URL, withArguments: methodArguments)
        print("Got url \(url)")
        
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        let task = sharedSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let error = error {
                print("Got error \(error)")
                completion(nil, error: error)
                return
            }
            
            guard let data = data else {
                print("No data in response")
                completion(nil, error: NSError(domain: DBDownloader.kDBDownloaderErrorDomain, code: -1, userInfo: nil))
                return
            }
            
            var jsonResults: [AnyObject]?
            var error: NSError?
            
            defer {
                // Always call the completion hander on exit
                print("Calling completion handler")
                completion(jsonResults, error: error)
            }
            
            do {
                if let rootResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject] {
                    guard let resultsArray = rootResult[DataConstants.RESULTS_KEY] as? [AnyObject] else {
                        fatalError("Failed to get key: \(DataConstants.RESULTS_KEY)")
                    }
                        
                    // Filter all of the top level objects and remove any elements that are not
                    // of the class "http://dbpedia.org/ontology/Aircraft"
                    jsonResults = resultsArray.filter({ (element) -> Bool in
                        let classes = self.getClasses(element as! [String: AnyObject])
                        for c in classes {
                            let uri = c["uri"]! as String
                            if uri == DBDownloader.DataConstants.AIRCRAFT_CLASS {
                                return true
                            }
                        }
                        
                        return false
                    })
                    
                    guard let jsonResults = jsonResults else {
                        print("No filtered results found")
                        return
                    }
                    
                    print("Found \(jsonResults.count) aircraft")
                    
                    let _ = jsonResults.map({ rawElement -> DBPediaLookupResult in
                        let elementDict = rawElement as! [String: AnyObject]
                        return DBPediaLookupResult(resourceURI: elementDict["uri"] as! String,
                            label: elementDict["label"] as! String,
                            abstract: elementDict["abstract"] as! String,
                            categories: [String: AnyObject]())
                    })
                    
                    // At this point, `jsonResults` has the results from the "lookup" API call that
                    // are aircraft. Now, request a data resource for each aircraft using the
                    // DBPedia API.
                    for element in jsonResults{
                        let e = element as! [String: AnyObject]
                        let uri = e["uri"] as! String
                        let dataURI = self.getDataURIFromResource(e["uri"] as! String)
                        self.downloadData(dataURI, completion: { (data, error) -> Void in
                            
                            if let error = error {
                                print("Error downloading data, error=\(error)")
                                return
                            }
                            
                            if let data = data {
                                
                                do {
                                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject],
                                        let _ = jsonResult[uri] as? [String: AnyObject] {
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            do {
                                                try self.sharedContext.save()
                                            } catch {}
                                        })
                                    }
                                } catch {
                                    print("Caught error creating JSON, error=\(error)")
                                    return
                                }
                            }
                        })
                    }
                }
            } catch let err as NSError {
                print("Failed to create JSON object, error=\(error)")
                error = err
            }
        }
    }
    
    /// Download data from a URL and pass it to the completion handler
    func downloadData(url: NSURL, completion: (data: NSData?, error: NSError?) ->Void) {
        print("Downloading data for: \(url.absoluteString)")
        
        let request = NSURLRequest(URL: url)
        let _ = sharedSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let error = error {
                print("Error downloading data")
                completion(data: nil, error: error)
                return
            }
            
            completion(data: data, error: nil)
        }
    }
       
    private func createURL(baseURL: String, withArguments arguments: [String: String]) -> NSURL {
        var methodString = String()
        for (key, value) in arguments {
            print("argument=\(key)")
            methodString += methodString.isEmpty ? "?" + key + "=" + value : "&" + key + "=" + value
        }
        
        print("methodString=\(methodString)")
        let fullURL = baseURL + methodString
        return NSURL(string: fullURL)!
    }
    
    /// Get a map of `classes` for a DBPedia "lookup" request
    private func getClasses(object: [String: AnyObject]) -> [[String: String]] {
        let o = object //as! [String: AnyObject]
        let classes = o["classes"] as! [[String: String]]
        return classes
    }

    /// Given a DBPedia resource URL, create the corresponding data URL that can be used to return
    /// the resource data as JSON.
    private func getDataURIFromResource(resourceURI: String) -> NSURL {
        let resourceName = NSURL(string: resourceURI)!.lastPathComponent!
        
        let fullURL = DBDownloader.DBPediaAPIConstants.DATA_URL + "/\(resourceName).json"
        
        return NSURL(string: fullURL)!
    }
}
