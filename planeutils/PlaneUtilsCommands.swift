//
//  PlaneUtilsCommands.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 1/31/16.
//  Copyright © 2016 notluS. All rights reserved.
//
import Foundation

/// Protocol that defines common functionality for all commands supported
protocol PlaneUtilsCommand {
    var filename: String? {get set}
    
    func execute() throws
}

/// Struct that defines the `exportdata` command
struct ExportPlaneDataCommand: PlaneUtilsCommand {
    var filename: String?
    
    func execute() throws {
        print("Executing 'exportdata' to file: \(filename)")
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
    }
}

struct GeneratePlaneDataCommand: PlaneUtilsCommand {
    var filename: String?
    
    func execute() throws {
        print("Executing 'generatedata'")
        let planeData = PlaneData()
        try planeData.getData({ () in
            CFRunLoopStop(CFRunLoopGetCurrent())
        })
    }
}
