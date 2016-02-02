//
//  Aircraft.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/5/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData

@objc(Aircraft)
class Aircraft : NSManagedObject {
    @NSManaged var name: String
    @NSManaged var abstract: String
    @NSManaged var uri: String
    @NSManaged var manufacturer: String
    @NSManaged var country: String
    @NSManaged var yearIntroduced: String
    @NSManaged var numberBuilt: String
    @NSManaged var crew: String
    @NSManaged var favorite: Bool
    @NSManaged var thumbnail: NSData
    @NSManaged var categories: Set<Category>
    @NSManaged var photos: Set<Photo>
    @NSManaged var modified: Bool
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Aircraft", inManagedObjectContext: context) else {
            fatalError()
        }
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        favorite = false
        modified = false
    }
}