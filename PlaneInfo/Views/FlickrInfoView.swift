//
//  FlickrInfoView.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 11/15/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import UIKit

class FlickrInfoView: UIView {

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    func showDownloading(downloading: Bool) {
        if downloading {
            hidden = false
            showNoInternet(false)
            activityView.hidden = false
            activityView.startAnimating()
            infoLabel.text = "Downloading photos"
        } else {
            activityView.hidden = true
            activityView.stopAnimating()
        }
    }
    
    func showNoInternet(noInternet: Bool) {
        if noInternet {
            hidden = false
            infoLabel.hidden = false
            retryButton.hidden = false
        } else {
            retryButton.hidden = true
        }
    }
    
    func showDownloadError(errorText: String) {
        hidden = false
        infoLabel.hidden = false
        infoLabel.text = errorText
        retryButton.hidden = false
        activityView.stopAnimating()
    }
}
