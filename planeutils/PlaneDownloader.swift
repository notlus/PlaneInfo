//
//  PlaneDownloader.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 1/30/16.
//  Copyright © 2016 notluS. All rights reserved.
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

class PlaneData {
    func getData() throws {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        let fetchResults = try sharedContext.executeFetchRequest(fetchRequest)
        if fetchResults.count == 0 {
            // Load categories
            // TODO: Don't hard code this path
            let categoriesPath = "/Users/jeffrey_sulton/development/Udacity/Projects/PlaneInfo/PlaneInfo/Resources/Categories.plist"
            guard let categories = NSDictionary(contentsOfFile: categoriesPath) as? [String: String] else {
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

        getDataForManufacturers(manufacturers)
    }
    
    private func getDataForManufacturers(manufacturers: [String]) {
        print("Starting download")
        
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
        for manufacturer in manufacturers {
            
            let lookupOp = LookupAircraftOp(searchTerm: manufacturer)
            operationQueue.addOperation(lookupOp)
            
            importOp.addDependency(lookupOp)
            
            lookupOp.completionBlock = {
                print("Lookup operation completed for \(manufacturer)")
                importOp.lookupResults.appendContentsOf(lookupOp.results)
            }
            
            gatherAircraftOp.addDependency(importOp)
        }
        
        gatherAircraftOp.completionBlock = {
            print("gather aircraft completed")
        }
        
        downloadDetails.addDependency(gatherAircraftOp)
        operationQueue.addOperation(downloadDetails)
        
        // Start operations
        operationQueue.suspended = false
    }
}
