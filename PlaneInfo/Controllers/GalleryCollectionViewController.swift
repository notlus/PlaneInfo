//
//  GalleryCollectionViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/14/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import UIKit

protocol SavePhotosDelegate {
    func save(flickrPhotos: [FlickrPhoto])
}

class GalleryCollectionViewController: UIViewController,
    NSFetchedResultsControllerDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    SavePhotosDelegate {

    // The `Aircraft` to which the gallery of photos belongs
    var aircraft: Aircraft?

    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: Core Data
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        guard let aircraft = self.aircraft else {
            return NSFetchedResultsController()
        }

        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "localPath", ascending: true)]
        
        // Create a predicate that retrieves all photos for the provided aircraft
        fetchRequest.predicate = NSPredicate(format: "aircraft == %@", aircraft)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()

//    private lazy var cachesDirectory: NSURL = {
//        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
//    }()

    private let reuseIdentifier = "GalleryCell"

    /// A dictionary that maps `NSFetchedResultsChangeType`s to an array of `NSIndexPaths`s
    private var objectChanges = [NSFetchedResultsChangeType: [NSIndexPath]]()
    
    private var selectedIndexPath: NSIndexPath?

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var backroundImageView: UIImageView!
    @IBOutlet weak var findPhotosButton: UIButton!
    
    // MARK: View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.clearColor()
        
        do {
            try fetchedResultsController.performFetch()
            fetchedResultsController.delegate = self
        }
        catch {
            fatalError("Fetch failed, error: \(error)")
        }
        
        if fetchedResultsController.fetchedObjects?.count > 0 {
            collectionView.hidden = false
            findPhotosButton.hidden = true
            backroundImageView.hidden = true
        }
        
        print("fetched \(fetchedResultsController.fetchedObjects!.count) photos")
    }

    @IBAction func loadFlickrVC() {
        print("loadFlickrVC")
        performSegueWithIdentifier("ShowFlickrVC", sender: self)
    }
    
    // MARK: SavePhotosDelegate
    
    func save(flickrPhotos: [FlickrPhoto]) {
        print("Saving photos")
        sharedContext.performBlock { () -> Void in
            for flickrPhoto in flickrPhotos {
                // Move the photo to the gallery directory
                if !self.movePhotoToGallery(flickrPhoto.localPath) {
                    // TODO: Should we alert the user here? Maybe keep a running total of photos
                    //       and report a single time to the user.
                    print("Unable to copy photo \(flickrPhoto.localPath) to gallery")
                    continue
                }
                
                // Create a `Photo` object for the photo
                let _ = Photo(localPath: flickrPhoto.localPath.lastPathComponent!, remotePath: flickrPhoto.remotePath.absoluteString, aircraft: self.aircraft!, context: self.sharedContext)
            }
            
            do {
                try self.sharedContext.save()
            } catch {
                fatalError("Failed to save context after saving photos")
            }
            
            // Now that we have some photos, show the collection view and hide the background view 
            // and the find button.
            self.collectionView.hidden = false
            self.findPhotosButton.hidden = true
            self.backroundImageView.hidden = true
        }
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
        guard let photo = fetchedResultsController.objectAtIndexPath(indexPath) as? Photo else {
            fatalError("Failed to get object from index path \(indexPath.row)")
        }
        
        let photoPath = getGalleryPathForPhoto(photo.localPath)
        let image = UIImage(contentsOfFile: photoPath)
        cell.imageView.image = image
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
            flickrVC.delegate = self
        } else if segue.identifier == "ShowPhotoVC"{
            guard let photoVC = segue.destinationViewController as? AircraftPhotoViewController,
                let indexPath = selectedIndexPath else {
                return
            }
            
            guard let photo = fetchedResultsController.objectAtIndexPath(indexPath) as? Photo else {
                return
            }
            
            let photoPath = getGalleryPathForPhoto(photo.localPath)

            photoVC.photoPath = photoPath
            photoVC.aircraftName = aircraft?.name
            
        } else {
            fatalError("Unknown segue: \(segue.identifier)")
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        performSegueWithIdentifier("ShowPhotoVC", sender: self)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: -10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }

    // MARK: FetchedResultsControllerDelegate

    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                print("Got insert")
                if let insertIndexPath = newIndexPath {
                    var arr = objectChanges[type]
                    if arr == nil {
                        arr = [NSIndexPath]()
                    }
                    arr?.append(insertIndexPath)
                    objectChanges[type] = arr
                }
            default:
                fatalError("Unsupported change type: \(type)")
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("controllerDidChangeContent, changes count: \(self.objectChanges.count)")
        
        collectionView.performBatchUpdates({ () -> Void in
            for (changeType, indexPaths) in self.objectChanges {
                switch changeType {
                case .Insert:
                    print("Inserting \(indexPaths.count) index paths")
                    self.collectionView.insertItemsAtIndexPaths(indexPaths)
                    self.objectChanges[changeType]?.removeAll()
                    
                default:
                    fatalError("Unexpected change type: \(changeType)")
                }
            }
            }) { (finished) -> Void in
                print("Finished with batch updates, finished = \(finished)")
                
                self.objectChanges.removeAll()
                self.collectionView.reloadData()
        }
        
        print("Exiting controllerDidChangeContent")
    }
    
    /// Get the full path to the photo
    private func getGalleryPathForPhoto(photoName: String) -> String {
        if let photoURL = NSURL(string: "\(appDelegate.galleryPath)\(photoName)"),
            let photoPath = photoURL.path {
                return photoPath
        }

        // Just return the original name
        return photoName
    }
    
    /// Move a photo at `sourcePhotoPath` to the "Gallery" directory
    private func movePhotoToGallery(sourcePhotoPath: NSURL) -> Bool {
        guard let sourcePath = sourcePhotoPath.path,
            var galleryPath = appDelegate.galleryPath.path else {
                return false
        }
        
        galleryPath = "\(galleryPath)/\(sourcePhotoPath.lastPathComponent!)"
        print("galleryPath=\(galleryPath)")
        
        do {
            try NSFileManager.defaultManager().moveItemAtPath(sourcePath, toPath: galleryPath)
            return true
        } catch {
            print("Failed to move photo from \(sourcePhotoPath) to \(galleryPath), error=\(error)")
        }
        
        return false
    }

}
