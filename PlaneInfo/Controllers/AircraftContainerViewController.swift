//
//  AircraftInfoViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/9/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import UIKit

class AircraftContainerViewController: UIViewController {

    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var galleryContainerView: UIView!
    
    var aircraft: Aircraft?
    
    private var favoriteEnabled: UIBarButtonItem!
    private var favoriteButtonDisabled: UIBarButtonItem!
    private var defaultTintColor: UIColor!
    
    private var galleryVC: GalleryCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defaultTintColor = navigationItem.rightBarButtonItem?.tintColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star"), style: .Plain, target: self, action: "toggleFavorite")
        
        if aircraft!.favorite == true {
            navigationItem.rightBarButtonItem?.tintColor = defaultTintColor
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGrayColor()
        }
        
        // Start with the info view
        infoContainerView.hidden = false
        detailsContainerView.hidden = true
        galleryContainerView.hidden = true
        self.tabBarController!.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }
    
    func toggleFavorite() {
        print("toggleFavorite")
        
        aircraft!.favorite = !aircraft!.favorite
        if aircraft!.favorite == true {
            navigationItem.rightBarButtonItem?.tintColor = defaultTintColor
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGrayColor()
        }
    }

    @IBAction func segmentChanged(sender: UISegmentedControl) {
        print("Segment \(sender.selectedSegmentIndex)")
        if sender.selectedSegmentIndex == 0 {
            // Show info
            infoContainerView.hidden = false
            detailsContainerView.hidden = true
            galleryContainerView.hidden = true
        } else if sender.selectedSegmentIndex == 1 {
            // Show details
            infoContainerView.hidden = true
            detailsContainerView.hidden = false
            galleryContainerView.hidden = true
        } else if sender.selectedSegmentIndex == 2 {
            // Show gallery
            infoContainerView.hidden = true
            detailsContainerView.hidden = true
            galleryContainerView.hidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: galleryVC, action: "loadFlickrVC")
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AircraftDetailsSegue" {
            let destination = segue.destinationViewController as! AircraftDetailsTableViewController
            destination.aircraft = aircraft
        } else if segue.identifier == "AircraftGallerySegue" {
            let destination = segue.destinationViewController as! GalleryCollectionViewController
            destination.aircraft = aircraft
            galleryVC = destination
        } else if segue.identifier == "AircraftInfoSegue" {
            let destination = segue.destinationViewController as! AircraftInfoViewController
            destination.aircraft = aircraft
            
        }
    }
}
