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
    
    @IBAction func endEditingText(sender: NSTextField) {
        print("endEditingText, dirty=\(dirty)")
        let row = tableView.rowForView(sender)
        let column = tableView.columnForView(sender)
        if dirty {
            print("Saving change")
            if column == 0 {
                aircraft[row].name = sender.stringValue
            } else if column == 1 {
                aircraft[row].manufacturer = sender.stringValue
            }
            try! sharedContext.save()
        }
    }
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    /// Array of `Aircraft` to use as the data source
    private var aircraft = [Aircraft]()
    
    private var dirty = false
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "textDidChange:",
                                                         name: NSControlTextDidChangeNotification,
                                                         object: nil)
        tableView.reloadData()
    }
    
    func textDidChange(notification: NSNotification) {
        print("textDidChange")
        dirty = true
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

extension BrowserWindowController: NSWindowDelegate {
    func windowWillClose(notification: NSNotification) {
        print("windowWillClose")
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
            cellView.imageView?.image = NSImage(data: aircraft[row].thumbnail)
            cellView.textField?.editable = true
        } else if tableColumn?.identifier == "ManufacturerColumn" {
            cellView.textField?.stringValue = aircraft[row].manufacturer
            cellView.textField?.editable = true
        }
        
        return cellView
    }
}
