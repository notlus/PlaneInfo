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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let aircraft = aircraft {
            nameLabel.text = aircraft.name
            if let image = UIImage(data: aircraft.thumbnail) {
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "NoPhotoImage")
            }
            
            abstractTextView.text = aircraft.abstract
        }
    }
    
    override func viewDidLayoutSubviews() {
        abstractTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
}
