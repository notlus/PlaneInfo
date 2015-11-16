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
    
    private func createAircraft(lookupResult: DBPediaLookupResult) {
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
        let categories = getCategoryForAircraft(lookupResult)
        categoryRequest.predicate = NSPredicate(format: "name IN %@", categories)
        var categoryResult: [Category]?
        do {
            categoryResult = try sharedContext.executeFetchRequest(categoryRequest) as? [Category]
        } catch {
            fatalError("Error executing fetch request: \(error)")
        }

        ac.categories = Set<Category>(categoryResult!)
    }
    
    func getCategoryForAircraft(aircraft: DBPediaLookupResult) -> Set<String> {
        var categories = Set<String>()
        if aircraft.abstract.lowercaseString.rangeOfString("commercial") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("civil") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("passenger") != nil {
            categories.insert("Civilian")
        }

        if aircraft.abstract.lowercaseString.rangeOfString("military") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("united states air force") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("united states navy") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("united states marine") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("world war") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("fighter") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("armed forces") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("strike") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("bomber") != nil {
                categories.insert("Military")
        }

        if (aircraft.abstract.lowercaseString.rangeOfString("world war ii") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("world war 2") != nil) &&
            !aircraft.abstract.lowercaseString.containsString("post-world war") &&
            !aircraft.abstract.lowercaseString.containsString("post world war") {
            categories.insert("World War 2")
        } else if (aircraft.abstract.lowercaseString.rangeOfString("world war i") != nil ||
            aircraft.abstract.lowercaseString.rangeOfString("world war 1") != nil) &&
            !aircraft.abstract.lowercaseString.containsString("post-world war") &&
            !aircraft.abstract.lowercaseString.containsString("post world war") {
                categories.insert("World War 1")
        }

        if aircraft.abstract.lowercaseString.rangeOfString("experimental") != nil {
            categories.insert("Experimental")
        }

        return categories
    }
}
