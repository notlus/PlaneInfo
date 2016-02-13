//
//  BrowserWindowController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 2/11/16.
//  Copyright © 2016 notluS. All rights reserved.
//

import Cocoa

protocol AircraftChange {
    func save()
}

class BrowserWindowController: NSWindowController, AircraftChange {

    @IBOutlet weak var tableView: NSTableView!
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    private var aircraft = [Aircraft]()
    
    /// Factory method
    class func Create() -> BrowserWindowController {
        let browser = BrowserWindowController(windowNibName: "BrowserWindowController")
        return browser
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.title = "Plane Browser"
        
        let selector: Selector = "handleDoubleClick:"
        tableView.doubleAction = selector
        tableView.target = self
        
        let fetchRequest = NSFetchRequest(entityName: "Aircraft")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Aircraft]
            aircraft = fetchResults!
        } catch {
            fatalError("Caught error: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func handleDoubleClick(sender:AnyObject) {
        let wc = EditorMainWindowController.CreateWithAircraft(aircraft[tableView.clickedRow], delegate: self)
        wc.showWindow(self)
    }
    
    func save() {
        print("Saving data")
        try! sharedContext.save()
    }
}

extension BrowserWindowController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return aircraft.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeViewWithIdentifier("NameColumn", owner: self) as! NSTableCellView
        if tableColumn?.identifier == "NameColumn" {
            cellView.textField?.stringValue = aircraft[row].name
        } else if tableColumn?.identifier == "ManufacturerColumn" {
            cellView.textField?.stringValue = aircraft[row].manufacturer
        }
        
        return cellView
    }
}
