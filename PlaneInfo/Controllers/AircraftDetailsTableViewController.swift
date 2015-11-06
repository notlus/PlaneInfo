//
//  AircraftDetailsTableViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/12/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import UIKit

/// Static table view for aircraft details
class AircraftDetailsTableViewController: UITableViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var firstYearLabel: UILabel!
    @IBOutlet weak var numberBuiltLabel: UILabel!
    @IBOutlet weak var crewLabel: UILabel!

    var aircraft: Aircraft?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let aircraft = aircraft {
            nameLabel.text = aircraft.name
            manufacturerLabel.text = aircraft.manufacturer
            
            let country = aircraft.country ?? "Unknown"
            countryLabel.text = !country.isEmpty ? country : "Unknown"
            
            let firstYear = aircraft.yearIntroduced ?? "Unknown"
            firstYearLabel.text = !firstYear.isEmpty ? firstYear : "Unknown"
            
            numberBuiltLabel.text = aircraft.numberBuilt
            
            crewLabel.text = aircraft.crew
        }
    }
}
