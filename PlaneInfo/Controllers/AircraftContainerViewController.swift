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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start with the info view
        infoContainerView.hidden = false
        detailsContainerView.hidden = true
        galleryContainerView.hidden = true
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
        } else if segue.identifier == "AircraftInfoSegue" {
            let destination = segue.destinationViewController as! AircraftInfoViewController
            destination.aircraft = aircraft
            
        }
    }
}
