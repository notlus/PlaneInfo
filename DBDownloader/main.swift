//
//  main.swift
//  DBDownloader
//
//  Created by Jeffrey Sulton on 10/1/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import Foundation

private var sharedContext: NSManagedObjectContext {
    return CoreDataManager.sharedInstance.managedObjectContext
}

/// Parent operation that waits for the download and import operations
class GatherAircraftOp: Operation {

    override func execute() {
        if cancelled {
            finish()
            return
        }
        
        print("Executing GatherAircraftOp")
        
        finish()
    }
}

func gatherAircraft() {
    print("Starting download")

    let searches = ["Airbus", "Boeing", "Lockheed", "Northrop_Grumman", "McDonnell_Douglas", "General_Dynamics", "Curtiss_Wright"]

    let operationQueue = NSOperationQueue()
    operationQueue.suspended = true
    
    let gatherAircraftOp = GatherAircraftOp()
    operationQueue.addOperation(gatherAircraftOp)

    // Add operation to download the details for each aircraft
    let downloadDetails = DownloadAircraftDetailsOp()
    downloadDetails.completionBlock = {
        print("DownloadAircraftDetailsOp completed")
    }

    let importOp = ImportLookupDataOp()
    importOp.completionBlock = {
        print("Import operation completed")
    }
    operationQueue.addOperation(importOp)

    // Perform a search for all search items
    for searchTerm in searches {
    
        let lookupOp = LookupAircraftOp(searchTerm: searchTerm)
        operationQueue.addOperation(lookupOp)
        
        importOp.addDependency(lookupOp)
        
        lookupOp.completionBlock = {
            print("Lookup operation completed for \(searchTerm)")
            importOp.lookupResults.appendContentsOf(lookupOp.results)
        }
        
        gatherAircraftOp.addDependency(importOp)
    }
    
    gatherAircraftOp.completionBlock = {
        print("gather aircraft completed")// with \(lookupResults.count) aircraft")
//        CFRunLoopStop(CFRunLoopGetMain())
    }

    downloadDetails.addDependency(gatherAircraftOp)
    operationQueue.addOperation(downloadDetails)
    
    // Start operations
    operationQueue.suspended = false
}

gatherAircraft()

CFRunLoopRun()

print("Done")
