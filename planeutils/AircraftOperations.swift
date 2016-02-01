//
//  AircraftOperations.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 1/31/16.
//  Copyright © 2016 notluS. All rights reserved.
//

import Foundation

/// Parent operation that waits for the download and import operations to complete
class AircraftDataOperation: Operation {
    
    override func execute() {
        if cancelled {
            finish()
            return
        }
        
        print("Executing AircraftDataOperation")
        
        finish()
    }
}
