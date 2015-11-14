//
//  AircraftPhotoViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 11/14/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import UIKit

class AircraftPhotoViewController: UIViewController {

    var aircraftName: String?
    var photoPath: String?
    
    @IBOutlet weak var aircraftPhoto: UIImageView! {
        didSet {
            print("Setting photo for aircraft")
            if let path = photoPath {
                aircraftPhoto.image = UIImage(contentsOfFile: path)
            }
        }
    }
    
    @IBOutlet weak var aircraftTitle: UINavigationItem! {
        didSet {
            if let name = aircraftName {
                aircraftTitle.title = name
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        

    }
}
