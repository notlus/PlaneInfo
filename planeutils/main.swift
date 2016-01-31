//
//  main.swift
//  planeutils
//
//  Created by Jeffrey Sulton on 1/30/16.
//  Copyright © 2016 notluS. All rights reserved.
//
import Foundation

/// Protocol that defines common functionality for all options supported
protocol UtilsOption {
    var filename: String? {get set}
    
    func execute() throws
}

/// Struct that defines the `Export` operation
struct Export: UtilsOption {
    var filename: String?
    
    func execute() throws {
        print("Executing 'Export' to file: \(filename)")
    }
}

/// Struct that defines the `GetData` operation
struct GetData: UtilsOption {
    var filename: String?
    
    func execute() throws {
        print("Executing 'GetData'")
        let planeData = PlaneData()
        try planeData.getData()
    }
}

enum PlaneUtilsErrors: ErrorType {
    case InvalidOption
}

// Valid states during command line processing
private enum CommandLineState {
    case Start, Running, Command, GatherData, File, Done
}

private var operation: UtilsOption?;
//private var operation = UtilsOperation.None

/// Commands come in the form "<command> --file <filename>
func processCommandLine(arguments: [String]) throws {
    var state = CommandLineState.Start
    
    for argument in arguments {
        switch argument {
        case "export":
            // Retrieve names of aircraft from Core Data
            print("Retrieve names")
            operation = Export()
        case "updatedata":
            // Download data about aircraft
            print("Download aircraft data")
            operation = GetData()
        case "--file":
            state = .File
        default:
            switch state {
            case .File:
                operation?.filename = argument
                continue
            case .Start:
                state = .Running
                continue
            default: break
            }
            
            print("Unknown option: \(argument)")
            throw PlaneUtilsErrors.InvalidOption
        }
    }
}

do {
    try processCommandLine(Process.arguments)
    try operation?.execute()
} catch let error {
    print("Caught error: \(error)")
    exit(EXIT_FAILURE)
}

print("All done")
