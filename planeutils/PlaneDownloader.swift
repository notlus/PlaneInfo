//
//  PlaneDownloader.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 1/30/16.
//  Copyright © 2016 notluS. All rights reserved.
//

import CoreData
import Foundation

class PlaneData {
    private let acErrorDomain = "com.notlus.acdownloader"
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }

    private lazy var documentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
                                                               inDomains: .UserDomainMask).first!
    }()
    
    func getData(completion: ()->()) throws {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        let fetchResults = try sharedContext.executeFetchRequest(fetchRequest)
        if fetchResults.count == 0 {
            // Load categories
            let categoriesPath = documentsDirectory.URLByAppendingPathComponent("Categories.plist")
            guard let categories = NSDictionary(contentsOfURL: categoriesPath) as? [String: String] else {
                print("Failed to create dictionary from plist")
                throw NSError(domain: acErrorDomain, code: 901, userInfo: nil)
            }
            
            for (_, value) in categories {
                let _ = Category(name: value, context: sharedContext)
            }
            
            try sharedContext.save()
        }
        
        let manufacturers = ["Airbus", "Boeing", "Lockheed", "Northrop_Grumman", "McDonnell_Douglas",
                        "General_Dynamics", "Curtiss_Wright", "Fokker", "Messerschmitt", "Focke-Wulf",
                        "North_American", "Supermarine", "Sukhoi", "Rockwell", "Mikoyan", "Dassault"]

        getDataForSearchTerms(manufacturers, completion: completion)
    }
    
    /// Creates new Core Data entities 
    func getDataForSearchTerms(searchTerms: [String], completion: () -> ()) {
        print("Starting download")
        
        let operationQueue = NSOperationQueue()
        operationQueue.suspended = true
        
        let aircraftDataOperation = AircraftDataOperation()
        aircraftDataOperation.completionBlock = {
            print("Aircraft data operation completed")
        }

        operationQueue.addOperation(aircraftDataOperation)
        
        let importOp = ImportLookupDataOp()
        importOp.completionBlock = {
            print("Import operation completed")
        }
        
        operationQueue.addOperation(importOp)
        
        // Create a `LookupAircraftOp` operation for each search term and import the results into
        // the Core Data model using the `ImportLookupDataOp` operation. After these complete, the
        // `DownloadAircraftDetailsOp` operation is used to download detailed information about 
        // each aircraft.
        for searchTerm in searchTerms {
            
            let lookupOp = LookupAircraftOp(searchTerm: searchTerm)
            operationQueue.addOperation(lookupOp)
            
            importOp.addDependency(lookupOp)
            
            lookupOp.completionBlock = {
                print("Lookup operation completed for \(searchTerm)")
                importOp.lookupResults.appendContentsOf(lookupOp.results)
            }
            
            // `aircraftDataOperation` is dependent on `importOp`.
            aircraftDataOperation.addDependency(importOp)
        }
        
        // Add operation to download the details for each aircraft
        let downloadDetails = DownloadAircraftDetailsOp()
        downloadDetails.completionBlock = {
            print("DownloadAircraftDetailsOp completed")
            completion()
        }
        
        // `downloadDetails` is dependent on `aircraftDataOperation`.
        downloadDetails.addDependency(aircraftDataOperation)
        operationQueue.addOperation(downloadDetails)
        
        // Start operations
        operationQueue.suspended = false
    }
}
