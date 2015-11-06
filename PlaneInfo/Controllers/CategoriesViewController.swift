//
//  CategoriesViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/7/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import UIKit

class CategoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    private var categories = [Category]()
    private var selectedCategoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Categories"
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "cid", ascending: true)]
        do {
            categories = try sharedContext.executeFetchRequest(fetchRequest) as! [Category]
        } catch {
            print("Fetch request failed")
            fatalError()
        }
        
        print("Fetched \(categories.count) categories")
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue")
        
        if let destination = segue.destinationViewController as? AllAircraftViewController {
            destination.category = categories[selectedCategoryIndex]
        }
    }
}

// MARK: UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Selected row \(indexPath.row)")
        selectedCategoryIndex = indexPath.row
        performSegueWithIdentifier("ShowCategorySegue", sender: self)
    }
}

// MARK:  UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
}
