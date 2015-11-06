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
        
        print("ImportLookupDataOp")
        
        sharedContext.performBlock { () -> Void in
//            if let lookupResults = self.lookupResults {
                for lookupResult in self.lookupResults {
                    if self.cancelled {
                        self.finish()
                        break
                    }
                    
                    let _ = self.createAircraft(lookupResult)
                }
                
                do {
                    try self.sharedContext.save()
                } catch {
                }
                
//            } else {
//                print("Failed to unwrap lookupResults")
//            }
            
            self.finish()
        }
    }
    
    private func createAircraft(lookupResult: DBPediaLookupResult) -> Aircraft {
        let ac = Aircraft(context: sharedContext)
        ac.abstract = lookupResult.abstract
        ac.uri = lookupResult.resourceURI
        ac.name = lookupResult.label
        return ac
    }
}
