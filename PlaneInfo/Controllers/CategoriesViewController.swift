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
    
    // TODO: These colors should be a part of the `Category` entity, so that they can stay in sync
    private let colors = [UIColor.purpleColor(),
        UIColor(red: 31/255, green: 58/255, blue: 147/255, alpha: 1.0),
        UIColor.blueColor(),
        UIColor(red: 58/255, green: 83/255, blue: 155/255, alpha: 1.0),
        UIColor(red: 65/255, green: 131/255, blue: 215/255, alpha: 1.0),
        UIColor(red: 25/255, green: 181/255, blue: 254/255, alpha: 1.0),
        UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1.0)]
    
    private var selectedCategoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Categories"
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            categories = try sharedContext.executeFetchRequest(fetchRequest) as! [Category]
        } catch {
            print("Fetch request failed")
            fatalError()
        }
        
        print("Fetched \(categories.count) categories")
    }

    override func viewDidLayoutSubviews() {
        tableView.setContentOffset(CGPoint(x: 0, y: -30), animated: false)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAircraftSegue" {
            guard let aircraftVC = segue.destinationViewController as? AircraftTableViewController else {
                return
            }
            
            aircraftVC.category = categories[selectedCategoryIndex]
        }
    }
}

// MARK: UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCategoryIndex = indexPath.row
        performSegueWithIdentifier("ShowAircraftSegue", sender: self)
    }
}

// MARK:  UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryTableViewCell
        cell.contentView.backgroundColor = colors[indexPath.row]
        cell.categoryView.backgroundColor = colors[indexPath.row]
        let category = categories[indexPath.row]
        cell.titleLabel.text = category.name
        if category.name == "Military" {
            cell.categoryImageView.image = UIImage(named: "Military")
        }
        else if category.name == "Civilian" {
            cell.categoryImageView.image = UIImage(named: "Civilian")
        }
        else if category.name == "World War 2" {
            cell.categoryImageView.image = UIImage(named: "WorldWar2")
        }
        else if category.name == "World War 1" {
            cell.categoryImageView.image = UIImage(named: "WorldWar1")
        }
        else if category.name == "Vietnam" {
            cell.categoryImageView.image = UIImage(named: "VietnamAircraft")
        }
        else if category.name == "Experimental" {
            cell.categoryImageView.image = UIImage(named: "ExperimentalAircraft")
        }
        
        return cell
    }
}
