//
//  ImageScrollView.swift
//  MemeMe
//
//  Created by Jeffrey Sulton on 4/16/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit

/// Adapted from the NYTScalingImageView class: https://github.com/NYTimes/NYTPhotoViewer
class ImageScrollView: UIScrollView, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        delegate = self
    }
    
    func setImage(image: UIImage) {
        // Set the content size of the scroll view to be the size of the image
        contentSize = image.size

        // Reset any zooming that might have occurred
        imageView.transform = CGAffineTransformIdentity
        
        imageView.image = image

        updateZoomScale()
        centerContent()
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerContent()
    }

    private func updateZoomScale() {
        if let image = imageView.image {
            // Calculate the ratio of the scroll view's width/height to the image's width/height
            let scaleWidth: CGFloat = bounds.size.width / image.size.width;
            let scaleHeight: CGFloat = bounds.size.height / image.size.height;
            
            // Scale by the smaller of the two ratios
            let minScale = fmin(scaleWidth, scaleHeight);
            
            minimumZoomScale = minScale;
            maximumZoomScale = 1.0;
            
            // Set the current zoom scale of the scroll view to the minimum value
            zoomScale = minimumZoomScale;
        }
    }
    
    private func centerContent() {
        var horizontalInset: CGFloat = 0;
        var verticalInset: CGFloat = 0;
        
        if (contentSize.width < CGRectGetWidth(bounds)) {
            horizontalInset = (CGRectGetWidth(bounds) - contentSize.width) * 0.5;
        }
        
        if (contentSize.height < CGRectGetHeight(bounds)) {
            verticalInset = (CGRectGetHeight(bounds) - contentSize.height) * 0.5;
        }
        
        // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    }
}
