//
//  GalleryCollectionViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/14/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import UIKit

class GalleryCollectionViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    // The `Aircraft` to which the gallery of photos belongs
    var aircraft: Aircraft?

    // MARK: Core Data
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        guard let aircraft = self.aircraft else {
            return NSFetchedResultsController()
        }
        
        // Create a predicate that retrieves all photos for the provided aircraft
//        fetchRequest.predicate = NSPredicate(format: "photo CONTAINS %@", aircraft)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()

    private let reuseIdentifier = "GalleryCell"

    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.clearColor()
        
//        do {
//            try fetchedResultsController.performFetch()
//            fetchedResultsController.delegate = self
//        }
//        catch {
//            print("Fetch failed")
//            fatalError()
//        }
        
//        print("fetched \(fetchedResultsController.fetchedObjects!.count) photos")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

/*
        if let aircraft = aircraft {
            FlickrClient.sharedInstance.downloadImagesForSearchTerm(aircraft.name) { (photos, error) -> () in
                if let error = error {
                    print("Error: \(error) downloading images")
                    return
                }
                
                print("Found \(photos?.count) photos")
                CoreDataManager.sharedInstance.saveContext()
            }
        }
*/
    }
    
    func loadFlickrVC() {
        print("loadFlickrVC")
        performSegueWithIdentifier("ShowFlickrVC", sender: self)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController.sections?[section])?.numberOfObjects ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? GalleryCollectionViewCell else {
            fatalError("Failed to dequeue GalleryCollectionViewCell")
        }
        
        // Configure the cell
        cell.imageView.image = UIImage(named: "IMG_0857")
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowFlickrVC" {
            print("Showing ShowFlickrVC")
            guard let flickrVC = segue.destinationViewController as? FlickrViewController else {
                return
            }
            
            flickrVC.searchTerm = aircraft?.name
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
