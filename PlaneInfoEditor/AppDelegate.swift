//
//  AppDelegate.swift
//  PlaneInfoEditor
//
//  Created by Jeffrey Sulton on 1/15/16.
//  Copyright © 2016 notluS. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindow: EditorMainWindowController!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        mainWindow = EditorMainWindowController.Create()
        mainWindow.showWindow(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}
