//
//  AircraftTableViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/1/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import UIKit
import CoreData

class AircraftTableViewController: UIViewController, NSFetchedResultsControllerDelegate, AllAircraftTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)

    var category: Category?
    
    private var searchResults = [Aircraft]()
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Aircraft")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        if let category = self.category {
            // Create a predicate that matches the category
            fetchRequest.predicate = NSPredicate(format: "categories.name CONTAINS %@", category.name)
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = ColorPalette.MainColor.color
        navigationController?.navigationBar.tintColor = ColorPalette.SecondaryColor.color
        tableView.backgroundColor = ColorPalette.LightColor.color
        
        // Set up the search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar

        // Adjust the content offset of the table view so that the search bar is not shown by
        // default.
        let offset = CGPointMake(0, searchController.searchBar.frame.size.height)
        tableView.contentOffset = offset

        if let category = category {
            navigationItem.title = "\(category.name) Aircraft"
        }
        
        do {
            try fetchedResultsController.performFetch()
            fetchedResultsController.delegate = self
        } catch {
            print("Caught error trying performFetch()")
        }
        
        print("fetched \(fetchedResultsController.fetchedObjects!.count) aircraft")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowContainerSegue" {
            if let destination = segue.destinationViewController as? AircraftContainerViewController {
                destination.aircraft = sender as? Aircraft
            }
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        let fetchResults = fetchedResultsController.fetchedObjects as! [Aircraft]
        searchResults = fetchResults.filter { aircraft in
            return aircraft.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    // MARK: AllAircraftTableViewCellDelegate
    
    func updateFavorite(favorite: Bool, indexPath: NSIndexPath) {
        if let aircraft = fetchedResultsController.objectAtIndexPath(indexPath) as? Aircraft {
            aircraft.favorite = favorite
            do {
                try sharedContext.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("AllAircraftViewController: controllerDidChangeContent")
    }
}

// MARK: UITableViewDelegate

extension AircraftTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Selected row \(indexPath.row)")
        
        let aircraft: Aircraft
        if searchController.active && searchController.searchBar.text != "" {
            aircraft = searchResults[indexPath.row]
        } else {
            aircraft = fetchedResultsController.objectAtIndexPath(indexPath) as! Aircraft
        }
        
        performSegueWithIdentifier("ShowContainerSegue", sender: aircraft)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
}

// MARK: UITableViewDataSource

extension AircraftTableViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return searchResults.count
        }
        
        let section = fetchedResultsController.sections?[section]
        let rows = section?.numberOfObjects ?? 0
        print("rows=\(rows)")
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AircraftCell") as! AllAircraftTableViewCell
        let aircraft: Aircraft
        if searchController.active && searchController.searchBar.text != "" {
            aircraft = searchResults[indexPath.row]
        } else {
            aircraft = fetchedResultsController.objectAtIndexPath(indexPath) as! Aircraft
        }
        
        cell.delegate = self
        cell.indexPath = indexPath
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
            cell.thumbnailImageView.image = UIImage(named: "NoPhotoImage")
        }
        
        return cell
    }
}

extension AircraftTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        return filterContentForSearchText(searchController.searchBar.text!)
    }
}