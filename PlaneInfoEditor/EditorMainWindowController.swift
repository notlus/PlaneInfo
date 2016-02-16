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

    /// Factory method to create an instance of `EditorMainWindowController`
    static func CreateWithAircraft(aircraft: Aircraft, delegate: AircraftChange) ->EditorMainWindowController {
        let editorWindow = EditorMainWindowController(aircraft)
        editorWindow.delegate = delegate
        return editorWindow
    }

    // MARK: Initializers
    
    convenience init(_ aircraft: Aircraft) {
        self.init(windowNibName: "EditorMainWindowController")
        
        currentAircraft = aircraft
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var delegate: AircraftChange?
    
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
    @IBOutlet weak var closeButton: NSButton!
    
    @IBAction func closeWindow(sender: AnyObject) {
        if dirty {
            try! sharedContext.save()
        }
        
        window?.close()
    }
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    // Track whether any data has be modified
    private var dirty: Bool = false {
        didSet {
            if dirty {
                closeButton.title = "Save"
            } else {
                closeButton.title = "Close"
            }
        }
    }
    
    private var currentAircraft: Aircraft?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.title = "Plane Editor"
        
        window?.backgroundColor = NSColor.whiteColor()
        
        populateUI()
    }
    
    // MARK: Actions
    
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
        currentAircraft!.abstract = textView.string!
    }
    
    func updateImage(newImage: NSImage?) {
        print("updateImage")
        if let image = newImage {
            currentAircraft!.thumbnail = image.TIFFRepresentation!
            try! sharedContext.save()
        }
    }

    private func updateAircraft(textField: NSTextField) {
        print("Updating aircraft")
        currentAircraft?.modified = true
        updateNameLabel()
        switch textField {
        case aircraftName:
            currentAircraft?.name = textField.stringValue
        case numberBuilt:
            currentAircraft?.numberBuilt = textField.stringValue
        case aircraftCountry:
            currentAircraft?.country = textField.stringValue
        case aircraftCrew:
            currentAircraft?.crew = textField.stringValue
        case aircraftManufacturer:
            currentAircraft?.manufacturer = textField.stringValue
        case aircraftIntroduced:
            currentAircraft?.yearIntroduced = textField.stringValue
        default:
            currentAircraft?.modified = false
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

    private func populateUI() {
        aircraftName.stringValue = currentAircraft!.name
        aircraftAbstract.string = currentAircraft!.abstract
        numberBuilt.stringValue = currentAircraft!.numberBuilt
        aircraftCountry.stringValue = currentAircraft!.country
        aircraftCrew.stringValue = currentAircraft!.crew
        aircraftManufacturer.stringValue = currentAircraft!.manufacturer
        aircraftIntroduced.stringValue = currentAircraft!.yearIntroduced
        let image = NSImage(data: currentAircraft!.thumbnail)
        thumnailImageView.image = image ?? NSImage(named: "NoPhotoImage")
        
        updateNameLabel()
    }
    
    private func updateNameLabel() {
        if currentAircraft!.modified {
            nameLabel.stringValue = "Name (modified)"
        } else {
            nameLabel.stringValue = "Name"
        }
    }
}

extension EditorMainWindowController: NSWindowDelegate {
    func windowWillClose(notification: NSNotification) {
        print("windowWillClose")
        if dirty {
            print("Something changed, saving")
            delegate?.save()
        }
    }
}
