//
//  GalleryCollectionViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/14/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import UIKit

class GalleryCollectionViewController: UICollectionViewController {
    // TODO: Move to GalleryCollectionViewCell
    private let reuseIdentifier = "GalleryCell"

    var aircraft: Aircraft?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

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
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 12
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? GalleryCollectionViewCell else {
            fatalError("Failed to dequeue GalleryCollectionViewCell")
        }
        
        // Configure the cell
        cell.imageView.image = UIImage(named: "IMG_0857")
        return cell
    }

    // MARK: UICollectionViewDelegate

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
