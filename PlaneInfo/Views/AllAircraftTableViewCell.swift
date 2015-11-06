//
//  AllAircraftTableViewCell.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 10/6/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import CoreData
import UIKit

protocol AllAircraftTableViewCellDelegate {
    func updateFavorite(favorite: Bool, indexPath: NSIndexPath) -> Void
}

class AllAircraftTableViewCell: UITableViewCell {
    
    var indexPath: NSIndexPath?
    var delegate: AllAircraftTableViewCellDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var unfavoriteButton: UIButton!
    
    // MARK: Actions
    @IBAction func markFavorite() {
        favoriteButton.hidden = true
        unfavoriteButton.hidden = false
        delegate?.updateFavorite(true, indexPath: indexPath!)
    }
    
    @IBAction func markUnfavorite() {
        favoriteButton.hidden = false
        unfavoriteButton.hidden = true
        delegate?.updateFavorite(false, indexPath: indexPath!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
