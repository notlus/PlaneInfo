//
//  PlaneUtilsCommands.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 1/31/16.
//  Copyright © 2016 notluS. All rights reserved.
//
import Foundation
import CoreData

/// Protocol that defines common functionality for all commands supported
protocol PlaneUtilsCommand {
    var filename: String? {get set}
    
    func execute() throws
}

/// Struct that defines the `importcategories` command
struct ImportPlaneCategoriesCommand: PlaneUtilsCommand {
    var filename: String?
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }

    func execute() throws {
        print("Importing categories from file: \(filename!)")
        
        guard let filename = filename else {
            throw NSError(domain: "com.notlus.planeutils", code: 998, userInfo: nil)
        }
        
        guard let categories = NSDictionary(contentsOfFile: filename) as? [String: String] else {
            throw NSError(domain: "com.notlus.planeutils", code: 997, userInfo: nil)
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        var newCategories = [String]()
        if let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Category] {
            // For each category
            for (_, value) in categories {
                if fetchResults.count == 0 {
                    newCategories.append(value)
                    continue
                }
                
                // Check whether it already exists in the fetch results
                var exists = false
                for fetchResult in fetchResults {
                    if value == fetchResult.name {
                        print("Category '\(value)' already exists")
                        exists = true
                        break
                    }
                }
                
                if !exists {
                    newCategories.append(value)
                }
            }
        }

        for (value) in newCategories {
            let _  = Category(name: value, context: sharedContext)
        }

        try sharedContext.save()
    }
}

/// Struct that defines the `exportdata` command
struct ExportPlaneDataCommand: PlaneUtilsCommand {
    var filename: String?
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    func execute() throws {
        print("Executing 'exportdata' to file: \(filename!)")
        let fetchRequest = NSFetchRequest(entityName: "Aircraft")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] 
        guard let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Aircraft] else {
            print("No data found for export")
            return
        }
        
        print("Found \(fetchResults.count) aircraft:\n")

        if let filename = filename,
            let outputStream = NSOutputStream(toFileAtPath: filename, append: true) {
            print("Saving data to file: \(filename)")
            outputStream.open()
            for result in fetchResults {
                let name = "\(result.name)\n"
                outputStream.write(name, maxLength: name.characters.count)
            }
            outputStream.close()
        } else {
            for result in fetchResults {
                print("\(result.name)")
            }
        }
    }
}

struct GeneratePlaneDataCommand: PlaneUtilsCommand {
    var filename: String?
    
    func execute() throws {
        print("Executing 'generatedata'")

        let searchData = try String(contentsOfFile: filename!)
        let searchTerms = searchData.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        
        let planeData = PlaneData()
        planeData.getDataForSearchTerms(searchTerms, completion: {
            CFRunLoopStop(CFRunLoopGetCurrent())
        })
        
        CFRunLoopRun()
    }
}
