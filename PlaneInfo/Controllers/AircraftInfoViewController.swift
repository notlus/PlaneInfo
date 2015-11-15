//
//  AircraftInfoViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/16/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import UIKit

class AircraftInfoViewController: UIViewController {

    var aircraft: Aircraft?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var abstractTextView: UITextView!
    
    @IBAction func handleTouch(sender: AnyObject) {
        if (sender.state == UIGestureRecognizerState.Ended) && aircraft?.thumbnail != nil {
            print("imageView has been tapped")
            performSegueWithIdentifier("ShowPhotoVC", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPhotoVC" {
            guard let photoVC = segue.destinationViewController as? AircraftPhotoViewController else {
                fatalError("Could not retrieve destination VC as AircraftPhotoViewController")
            }
            
            photoVC.aircraftName = aircraft?.name
            if let thumbnail = aircraft?.thumbnail {
                photoVC.photo = UIImage(data: thumbnail)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let aircraft = aircraft {
            nameLabel.text = aircraft.name
            if let image = UIImage(data: aircraft.thumbnail) {
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "NoPhotoImage")
                imageView.contentMode = .ScaleAspectFit
            }
            
            abstractTextView.text = aircraft.abstract
        }
    }
    
    override func viewDidLayoutSubviews() {
        abstractTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
}
