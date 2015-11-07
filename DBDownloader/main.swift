//
//  main.swift
//  DBDownloader
//
//  Created by Jeffrey Sulton on 10/1/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import Foundation

private let acErrorDomain = "com.notlus.acdownloader"

private var sharedContext: NSManagedObjectContext {
    return CoreDataManager.sharedInstance.managedObjectContext
}

/// Parent operation that waits for the download and import operations to complete
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

    let searches = ["Airbus", "Boeing", "Lockheed", "Northrop_Grumman", "McDonnell_Douglas",
        "General_Dynamics", "Curtiss_Wright", "Fokker", "Messerschmitt", "Focke-Wulf",
        "North_American", "Supermarine"] //, "Rockwell International"]

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

let fetchRequest = NSFetchRequest(entityName: "Category")

let fetchResults = try sharedContext.executeFetchRequest(fetchRequest)
if fetchResults.count == 0 {
    // Load categories
    let categoriesPath = "/Users/jeffrey_sulton/development/Udacity/Projects/PlaneInfo/PlaneInfo/Resources/Categories.plist"
    guard let categories = NSDictionary(contentsOfFile: categoriesPath) as? [String: String] else {
        print("Failed to create dictionary from plist")
        throw NSError(domain: acErrorDomain, code: 901, userInfo: nil)
    }

    for (key, value) in categories {
        let _ = Category(name: value, context: sharedContext)
    }

    try sharedContext.save()
}

gatherAircraft()

CFRunLoopRun()

print("Done")
