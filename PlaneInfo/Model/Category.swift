//
//  Catagory.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/10/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData

@objc(Category)
class Category: NSManagedObject {
    @NSManaged var cid: NSNumber
    @NSManaged var name: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: CoreDataManager.sharedInstance.managedObjectContext)
    }
    
    init(id: Int16, name: String, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: context) else {
            print("Failed to get `Category` entity")
            fatalError()
        }
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.cid = NSNumber(short: id)
        self.name = name
    }
}