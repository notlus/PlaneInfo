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

/// Struct that defines the `updatedata` command
struct UpdatePlaneDataCommand: PlaneUtilsCommand {
    var filename: String?
    
    func execute() throws {
        print("Executing 'updatedata'")
        let planeData = PlaneData()
        try planeData.getData({ () in
            CFRunLoopStop(CFRunLoopGetCurrent())
        })
        CFRunLoopRun()
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
