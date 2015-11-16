//
//  FlickrViewController.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 9/8/15.
//  Copyright (c) 2015 notluS. All rights reserved.
//

import CoreData
import UIKit

class FlickrViewController: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    
    var searchTerm: String?
    
    var photos = [FlickrPhoto]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.hidden = true
        }
    }
    
    @IBOutlet weak var collectionButton: UIButton! {
        didSet {
            collectionButton.enabled = false
        }
    }
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var infoView: FlickrInfoView! {
        didSet {
            infoView.hidden = true
        }
    }
    
    @IBOutlet weak var noImagesLabel: UILabel! {
        didSet {
            noImagesLabel.hidden = true
        }
    }

    // MARK: Private Properties
    
    private var selectedPhotos = Set<NSIndexPath>() {
        didSet {
            if selectedPhotos.count > 0 {
                collectionButton.enabled = true
            }
            else {
                collectionButton.enabled = false
            }
        }
    }
    
    private let reuseIdentifier = "PhotoCell"
    
    // MARK: Public Properties

    var delegate: SavePhotosDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDownload()
    }

    // MARK: Actions
    
    @IBAction func addPhotos() {
        dismissViewControllerAnimated(true, completion: nil)
        
        print("Adding \(selectedPhotos.count) photos")
        
        var flickrPhotos = [FlickrPhoto]()
        for photoIndex in selectedPhotos {
            flickrPhotos.append(photos[photoIndex.row])
        }
        
        delegate?.save(flickrPhotos)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func retryDownload() {
        startDownload()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? CollectionViewPhotoCell else {
            fatalError("Failed to dequeue CollectionViewPhotoCell")
        }
        
        var photo = photos[indexPath.row]
        
        if photo.downloaded {
            print("Photo downloaded")
            photoCell.photoView.image = UIImage(contentsOfFile: photo.localPath.absoluteString)
        } else {
            print("Downloading photo")
            photoCell.activityView.startAnimating()
            photoCell.photoView.hidden = true
            photoCell.overlayView.hidden = false
            
            downloadPhoto(photo, completion: { (image) -> () in
                if let image = image {
                    photo.downloaded = true
                    photoCell.photoView.hidden = false
                    photoCell.overlayView.hidden = true
                    photoCell.activityView.stopAnimating()
                    photoCell.photoView.image = image
                } else {
                    // There was an error downloading
                    photoCell.activityView.stopAnimating()
                    photoCell.overlayView.backgroundColor = UIColor.redColor()
                }
            })
        }
        
        photoCell.photoView.alpha = 1.0
        
        return photoCell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let photoCell = collectionView.cellForItemAtIndexPath(indexPath) as? CollectionViewPhotoCell else {
            fatalError("Failed to get photo cell at index path \(indexPath.row)")
        }
        
        if selectedPhotos.contains(indexPath) {
            // Unselect photo
            photoCell.photoView.alpha = 1.0
            selectedPhotos.remove(indexPath)
        } else {
            // Select photo
            selectedPhotos.insert(indexPath)
            photoCell.photoView.alpha = 0.25
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: -10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK:  Private Functions
    
    private func startDownload() {
        if FlickrClient.connectedToNetwork() {
            infoView.showDownloading(true)
            downloadPhotos()
        } else {
            print("No internet connection")
            infoView.showNoInternet(true)
        }
    }
    
    /// Use the Flickr search API to find photos for `searchTerm`
    private func downloadPhotos() -> Void {
        if let searchTerm = searchTerm {
            FlickrClient.sharedInstance.downloadImagesForSearchTerm(searchTerm) { (photos, error) -> () in
                if let error = error {
                    print("Error: \(error) downloading images")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.infoView.showDownloadError("A timeout occurred while downloading photos, please retry")
                    })
                    
                    return
                }
                
                if let photos = photos {
                    print("Found \(photos.count) photos")
                    self.photos += photos
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.hidden = false
                    self.infoView.showDownloading(false)
                })
            }
        }
    }
        
    private func downloadPhoto(photo: FlickrPhoto, completion: (image: UIImage?) -> ()) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if let data = FlickrClient.sharedInstance.downloadImageForPhoto(photo) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(image: UIImage(data: data))
                })
            }
        })
    }
}
