//
//  FavoritesTableViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/17/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import UIKit

class FavoritesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Aircraft")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Filter out any `Aircraft` that don't have a thumbnail image
        fetchRequest.predicate = NSPredicate(format: "favorite == true")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorites"
        
        do {
            try fetchedResultsController.performFetch()
            fetchedResultsController.delegate = self
        } catch {
            print("Caught error trying performFetch()")
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            
            switch type {
                case .Insert:
                    self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                case .Delete:
                    self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            default:
                    fatalError("Unexpected change")
            }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("Content changed")
    }

}

// MARK: UITableViewDelegate

extension FavoritesTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Selected row \(indexPath.row)")
        let aircraft = fetchedResultsController.objectAtIndexPath(indexPath) as! Aircraft
        performSegueWithIdentifier("ShowContainerSegue", sender: aircraft)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
}

// MARK: UITableViewDataSource

extension FavoritesTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController.sections?[section]
        let rows = section?.numberOfObjects ?? 0
        print("rows=\(rows)")
        return rows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AircraftCell") as! AllAircraftTableViewCell
//        cell.delegate = self
        cell.indexPath = indexPath
        if let aircraft = fetchedResultsController.objectAtIndexPath(indexPath) as? Aircraft {
            cell.nameLabel.text = aircraft.name
            if aircraft.favorite {
                cell.favoriteButton.hidden = true
                cell.unfavoriteButton.hidden = false
            } else {
                cell.favoriteButton.hidden = false
                cell.unfavoriteButton.hidden = true
            }
            
            if let image = UIImage(data: aircraft.thumbnail) {
                cell.thumbnailImageView.image = image
            } else {
                cell.thumbnailImageView.image = nil
            }
        }
        
        return cell
    }
}
