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
