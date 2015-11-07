//
//  ImportLookupDataOp.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 11/3/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import Foundation

class ImportLookupDataOp: Operation {
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }

    var lookupResults = [DBPediaLookupResult]()
    
    override func execute() {
        if cancelled {
            finish()
            return
        }
        
        sharedContext.performBlock { () -> Void in
            for lookupResult in self.lookupResults {
                if self.cancelled {
                    self.finish()
                    break
                }
                
                self.createAircraft(lookupResult)
            }
            
            do {
                try self.sharedContext.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
            
            self.finish()
        }
    }
    
    private func createAircraft(lookupResult: DBPediaLookupResult) { //-> Aircraft {
        let fetchRequest = NSFetchRequest(entityName: "Aircraft")
        fetchRequest.predicate = NSPredicate(format: "uri == %@", lookupResult.resourceURI)
        var fetchResults: [Aircraft]?
        
        do {
            fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Aircraft]
            if  fetchResults?.count > 0 {
                print("lookupResult \(lookupResult.resourceURI) already exists")
                return
            }
        } catch {
            fatalError("Error executing fetch request: \(error)")
        }
        
        
        let ac = Aircraft(context: sharedContext)
        ac.abstract = lookupResult.abstract
        ac.uri = lookupResult.resourceURI
        ac.name = lookupResult.label
        
        let categoryRequest = NSFetchRequest(entityName: "Category")
        let categoryName = "Military"
        categoryRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        var categoryResult: [Category]?
        do {
            categoryResult = try sharedContext.executeFetchRequest(categoryRequest) as? [Category]
        } catch {
            fatalError("Error executing fetch request: \(error)")
        }

        ac.categories = Set<Category>(categoryResult!)
    }
}
