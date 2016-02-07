//
//  main.swift
//  planeutils
//
//  Created by Jeffrey Sulton on 1/30/16.
//  Copyright © 2016 notluS. All rights reserved.
//
import Foundation

enum PlaneUtilsErrors: ErrorType {
    case InvalidOption
}

// Valid states during command line processing
private enum CommandLineState {
    case Start, Running, Command, GatherData, File, Done
}

/// Process command line arguments and return a PlaneUtilsOperationCommands come in the form "<command> --file <filename>
func processCommandLine(arguments: [String]) throws -> PlaneUtilsCommand {
    var state = CommandLineState.Start
    var command: PlaneUtilsCommand?;
    
    for argument in arguments {
        switch argument {
        case "exportdata":
            // Retrieve names of aircraft from Core Data
            print("Retrieve names")
            command = ExportPlaneDataCommand()
            state = .Done
        case "updatedata":
            // Download data about aircraft
            print("Download aircraft data")
            command = UpdatePlaneDataCommand()
            state = .Done
        case "generatedata":
            command = GeneratePlaneDataCommand()
        case "importcategories":
            command = ImportPlaneCategoriesCommand()
        case "--file":
            state = .File
        default:
            switch state {
            case .File:
                command?.filename = argument
                continue
            case .Start:
                state = .Running
                continue
            default:
                break
            }
            
            print("Unknown option: \(argument)")
            throw PlaneUtilsErrors.InvalidOption
        }
    }
    
    return command!
}

do {
    let command = try processCommandLine(Process.arguments)
    try command.execute()
} catch let error {
    print("Caught error: \(error)")
    exit(EXIT_FAILURE)
}

print("All done")
