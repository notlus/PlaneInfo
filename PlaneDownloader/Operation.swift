//
//  Operation.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 11/2/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import Foundation

class Operation: NSOperation {
    
    private var _executing = false {
        willSet {
            willChangeValueForKey("isRunning")
        }
        
        didSet {
            didChangeValueForKey("isRunning")
        }
    }
    
    private var _finished = false {
        willSet {
            willChangeValueForKey("isFinished")
        }
        
        didSet {
            didChangeValueForKey("isFinished")
        }
    }
    
    override var executing: Bool {
        return _executing
    }
    
    override var finished: Bool {
        return _finished
    }
    
    override func start() {
        super.start()
        _executing = true
        execute()
    }
    
    func execute() {
        fatalError("Do not call directly, a derived class must override")
    }
    
    func finish() {
        _executing = false
        _finished = true
    }
}
