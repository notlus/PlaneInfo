//
//  Photo.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/5/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData

@objc(Photo)
class Photo: NSManagedObject {
    @NSManaged var localPath: String
    @NSManaged var remotePath: String
    @NSManaged var aircraft: Aircraft
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(localPath: String, remotePath: String, aircraft: Aircraft, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) else {
            fatalError()
        }
        
        super.init(entity: entity, insertIntoManagedObjectContext: CoreDataManager.sharedInstance.managedObjectContext)
        
        self.localPath = localPath
        self.remotePath = remotePath
        self.aircraft = aircraft
    }
}
