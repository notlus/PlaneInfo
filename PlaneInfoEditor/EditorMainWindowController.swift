//
//  EditorMainWindowController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 1/15/16.
//  Copyright © 2016 notluS. All rights reserved.
//

import Cocoa

protocol UpdateImage {
    func updateImage(newImage: NSImage?)
}

class EditorMainWindowController: NSWindowController, NSTextViewDelegate, UpdateImage {

    // MARK: Outlets
    
    @IBOutlet weak var aircraftName: NSTextField!
    @IBOutlet var aircraftAbstract: NSTextView!
    @IBOutlet weak var numberBuilt: NSTextField!
    @IBOutlet weak var aircraftCountry: NSTextField!
    @IBOutlet weak var aircraftCrew: NSTextField!
    @IBOutlet weak var aircraftManufacturer: NSTextField!
    @IBOutlet weak var aircraftIntroduced: NSTextField!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var aircraftNumber: NSTextField!
    @IBOutlet weak var thumnailImageView: AircraftImageView! {
        didSet {
            thumnailImageView.delegate = self
        }
    }
    @IBOutlet weak var nameLabel: NSTextField!

    /// Factory method to create an instance of `EditorMainWindowController`
    class func Create() -> EditorMainWindowController {
        let editorWindow = EditorMainWindowController(windowNibName: "EditorMainWindowController")
        return editorWindow
    }
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    // The model, an array of `Aircraft`
    private var aircraft = [Aircraft]()
    
    // The currently selected `Aircraft`
    private var currentIndex = 0
    
    // Track whether any data has be modified
    private var dirty = false
    
    private var currentAircraft: Aircraft {
        return aircraft[currentIndex]
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
//        showOpenPanel("Choose the data store") { (selectedFile) -> Void in
//            print("Chose file \(selectedFile)")
            self.aircraft = try! self.fetchAircraft() ?? [Aircraft]()
            self.currentIndex = 0
//        }
        
        if aircraft.count > 0 {
            self.populateUI()
        }
        
        window?.title = "Plane Editor"
    }
    
    // MARK: Actions
    
    @IBAction func nextAircraft(sender: AnyObject) {
        if dirty {
            print("Saving context")
            try! sharedContext.save()
            dirty = false
        }
        
        currentIndex += 1
        populateUI()
    }
    
    @IBAction func previousAircraft(sender: AnyObject) {
        if dirty {
            print("Saving context")
            currentAircraft.modified = dirty
            try! sharedContext.save()
            dirty = false
        }
        
        currentIndex -= 1
        populateUI()
    }
    
    override func controlTextDidChange(notification: NSNotification) {
        print("controlTextDidChange")
        dirty = true
        updateAircraft(notification.object as! NSTextField)
    }
    
    override func controlTextDidEndEditing(notification: NSNotification) {
        print("controlTextDidEndEditing")
    }
    
    func textDidChange(notification: NSNotification) {
        print("Text view changed")
        dirty = true
        let textView = notification.object as! NSTextView
        currentAircraft.abstract = textView.string!
    }
    
    func updateImage(newImage: NSImage?) {
        print("updateImage")
        if let image = newImage {
            currentAircraft.thumbnail = image.TIFFRepresentation!
            try! sharedContext.save()
        }
    }

    private func updateAircraft(textField: NSTextField) {
        print("Updating aircraft")
        currentAircraft.modified = true
        updateNameLabel()
        switch textField {
        case aircraftName:
            currentAircraft.name = textField.stringValue
        case numberBuilt:
            currentAircraft.numberBuilt = textField.stringValue
        case aircraftCountry:
            currentAircraft.country = textField.stringValue
        case aircraftCrew:
            currentAircraft.crew = textField.stringValue
        case aircraftManufacturer:
            currentAircraft.manufacturer = textField.stringValue
        case aircraftIntroduced:
            currentAircraft.yearIntroduced = textField.stringValue
        default:
            currentAircraft.modified = false
            fatalError("Unknown text field")
        }
    }
    
    private func showOpenPanel(panelTitle: String, completion: (selectedFile: NSURL?) -> Void) {
        let openPanel = NSOpenPanel()
        let originalTitle = window?.title
        window?.title = panelTitle
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModalForWindow(self.window!) { (result) -> Void in
            if result == 1 {
                print("Something was selected")
                completion(selectedFile: openPanel.URL)
            } else {
                print("Open was canceled")
                completion(selectedFile: nil)
            }
            
            if let title = originalTitle {
                self.window?.title = title
            }
        }
    }

    private func fetchAircraft() throws -> [Aircraft]? {
        let fetchRequest = NSFetchRequest(entityName: "Aircraft")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return try sharedContext.executeFetchRequest(fetchRequest) as? [Aircraft]
    }
    
    private func populateUI() {
        let currentAircraft = aircraft[currentIndex]
        aircraftName.stringValue = currentAircraft.name
        aircraftAbstract.string = currentAircraft.abstract
        numberBuilt.stringValue = currentAircraft.numberBuilt
        aircraftCountry.stringValue = currentAircraft.country
        aircraftCrew.stringValue = currentAircraft.crew
        aircraftManufacturer.stringValue = currentAircraft.manufacturer
        aircraftIntroduced.stringValue = currentAircraft.yearIntroduced
        let image = NSImage(data: currentAircraft.thumbnail)
        thumnailImageView.image = image ?? NSImage(named: "NoPhotoImage")
        
        updateNameLabel()
        
        if currentIndex == 0 {
            previousButton.enabled = false
        } else {
            previousButton.enabled = true
        }
        
        if currentIndex == aircraft.count {
            nextButton.enabled = false
        } else {
            nextButton.enabled = true
        }
        
        aircraftNumber.stringValue = "\(currentIndex + 1) of \(aircraft.count)"
    }
    
    private func updateNameLabel() {
        if currentAircraft.modified {
            nameLabel.stringValue = "Name (modified)"
        } else {
            nameLabel.stringValue = "Name"
        }
    }
}
