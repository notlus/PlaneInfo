//
//  AppDelegate.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/1/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var documentsDirectory: NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
    }
    
    lazy var galleryPath: NSURL = {
        return self.documentsDirectory.URLByAppendingPathComponent("Gallery/")
    }()
    
    private let hasRunKey = "firstLaunch"
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }

    private func loadDefaultData() throws {
        if CoreDataManager.sharedInstance.storeExists() == false {
            let storePath = NSBundle.mainBundle().pathForResource("PlaneInfo", ofType: "sqlite")
            do {
                try CoreDataManager.sharedInstance.copyStoreFromPath(storePath!)
            } catch let error as NSError {
                fatalError("Failed to copy store to documents directory, error=\(error)")
            }
        }
        
        // Create the directory for the gallery photos
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(galleryPath.absoluteString) == false {
            // Create the gallery directory
            do {
                try fileManager.createDirectoryAtURL(galleryPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                fatalError("Failed to create path: \(galleryPath), error=\(error)")
            }
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let hasRun = defaults.boolForKey(hasRunKey)
        if !hasRun {
            // Initial launch of the app; copy over data store and create categories
            do {
                try loadDefaultData()
                defaults.setBool(true, forKey: hasRunKey)
            } catch {
                print("Caught error: \(error)")
                return false
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.sharedInstance.saveContext()
    }
}
