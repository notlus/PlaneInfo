//
//  main.swift
//  PlanePicture
//
//  Created by Jeffrey Sulton on 1/25/16.
//  Copyright © 2016 notluS. All rights reserved.
//

import Foundation

let flickrClient = FlickrClient.sharedInstance
//422008@N23
//2317226@N21
//2556169@N20

let groups = ["481553@N21", "1252802@N20", "1691294@N23", "2556169@N20","2317226@N21","422008@N23", "912570@N20", "81748198@N00", "2097535@N22", "1015362@N25"]
for group in groups {
    flickrClient.downloadPhotosForGroup(group) { (photos, error) in
        print("Got \(photos?.count) photos, starting download")
        // Here we have the photo info, and need to download the actual photos
        for photo in photos! {
            if let data = FlickrClient.sharedInstance.downloadImageForPhoto(photo) {
                print(".", separator: "", terminator: "")
            }
        }
        
        print("Finished download")
    }
}

CFRunLoopRun()
}

