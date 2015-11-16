//
//  FlickrClient.swift
//
//  Created by Jeffrey Sulton on 9/14/15.
//  Copyright (c) 2015 notluS. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

struct FlickrPhoto {
    var localPath: NSURL
    var remotePath: NSURL
    var downloaded: Bool
}

enum FlickrClientError: ErrorType {
    case InvalidSearch(String)
    case NoPhotosFound
    case Unknown
}

extension FlickrClientError: Equatable {}

func ==(lhs: FlickrClientError, rhs: FlickrClientError) -> Bool {
    switch (lhs, rhs) {
    default:
        return lhs._code == rhs._code
    }
}

public class FlickrClient {
    
    static let sharedInstance = FlickrClient()

    struct APIConstants {
        static let API_KEY = "7a7950524c71e50ecca5e2bd7535fe69"
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let API_METHOD = "flickr.photos.search"
        static let FORMAT = "json"
        static let EXTRAS = "url_m"
        static let MAX_PAGE = "210"
    }

    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private let session = NSURLSession.sharedSession()
    
    private let FLICKR_CLIENT_DOMAIN = "com.notlus.flickr"
    
    private lazy var documentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    }()

    private lazy var cachesDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
    }()

    /// Given a search term, attempt to download images from Flickr. Call the provided
    /// completion handler, providing an array of `Photo` instances or an error, when done.
    func downloadImagesForSearchTerm(searchTerm: String, completion: (photos: [FlickrPhoto]?, error: ErrorType?) -> ()) {
        if searchTerm.isEmpty {
            print("Nothing to search for")
            let error = FlickrClientError.InvalidSearch(searchTerm)
            completion(photos: nil, error: error)
        }
        
        let methodArguments = [
            "method": APIConstants.API_METHOD,
            "api_key": APIConstants.API_KEY,
            "format": APIConstants.FORMAT,
            "extras": APIConstants.EXTRAS,
            "per_page": APIConstants.MAX_PAGE,
            "text": searchTerm,
            "nojsoncallback": "1",
        ]
        
        getImageFromFlickr(methodArguments) { (photosData, error) -> () in
            if let error = error {
                print("Received an error downloading photos: \(error)")
                completion(photos: nil, error: error)
                return
            }
            
            print("Got \(photosData.count) photos")
            
            // Create an array of tuples, where the tuple contains the remote and local URLs for the
            // image.
            let photos = photosData.map({(photoData: [String: AnyObject]) -> (FlickrPhoto) in

                // Get the URL for the photo and create a tuple of the remote URL and a generated
                // filename
                if let photoString = photoData[APIConstants.EXTRAS] as? String,
                    let photoURL = NSURL(string: photoString) {
                    let filename = "\(NSDate().timeIntervalSince1970)-\(arc4random())"
                        let fullPath = "\(self.cachesDirectory)/\(filename)"
                        
                        return FlickrPhoto(localPath: NSURL(string: fullPath)!, remotePath: photoURL, downloaded: false)
                }

                return FlickrPhoto(localPath: NSURL(), remotePath: NSURL(), downloaded: false)
            })
            completion(photos: photos, error: nil)
        }
    }

    func downloadImageForPhoto(photo: FlickrPhoto) -> NSData? {
        let data: NSData
        do {
            data = try NSData(contentsOfURL: photo.remotePath, options: .DataReadingUncached)
        } catch {
            print("\(error)")
            return nil
        }
        
        if (!data.writeToURL(photo.localPath, atomically: true)) {
            print("Failed to write to URL: \(photo.localPath)")
            return nil
        }
        
        return data
    }

    func getLocalPhoto(photo: Photo) -> UIImage? {
        guard let fullPath = NSURL(string: photo.localPath, relativeToURL: appDelegate.galleryPath)  else {
            print("Failed to create full path from \(photo.localPath) and \(appDelegate.galleryPath)")
            return nil
        }

        return UIImage(contentsOfFile: fullPath.path!)
    }

    static func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }

    /// Using the supplied arguments, download images from Flickr. On completion, call the
    /// completion handler. The completion handler takes an array of `[String: AnyObject]`, where
    /// each element represents a photo from Flickr.
    private func getImageFromFlickr(arguments: [String: String], completion: (photoPaths: [[String: AnyObject]], error: ErrorType?) -> ()) {
        
        // Create a URL from the arguments
        if let flickrURL = createURLFromArguments(arguments) {
            let request = NSURLRequest(URL: flickrURL)
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if let err = error {
                    print("Request failed with error=\(err)")
                    completion(photoPaths: [[String: AnyObject]](), error: err)
                }
                else {
                    print("Request succeeded")
                    let httpResponse = response as! NSHTTPURLResponse
                    print("status: \(httpResponse.statusCode)")
                    let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! [String: AnyObject]
                    
                    // Get the `photos` dictionary from the parsed response
                    let photos = parsedResult["photos"] as! [String: AnyObject]
                    
                    // See if we got any results
                    let total = Int((photos["total"] as! String))!
                    if total > 0 {
                        let photoArray = photos["photo"] as! [[String: AnyObject]]
                        completion(photoPaths: photoArray, error: nil)
                    }
                    else {
                        completion(photoPaths: [[String: AnyObject]](), error: FlickrClientError.NoPhotosFound) //NSError(domain: self.FLICKR_CLIENT_DOMAIN, code: FlickClientError.NoPhotosFound, userInfo: nil))
                    }
                }
            }
            
            task.resume()
        }
        else
        {
            print("Failed to create Flickr URL")
        }
    }
    
    private func createURLFromArguments(arguments: [String: String]) -> NSURL? {
        var methodString = String()
        for (key, value) in arguments {
            methodString += (methodString.isEmpty ? "?" : "&") + key + "=" + value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLUserAllowedCharacterSet())!
        }
        
        let urlString = APIConstants.BASE_URL + methodString
        
        if let components = NSURLComponents(string: urlString) {
            print("Got components")
            return components.URL
        }
        
        return nil
    }

    private func createBoundingBox(lat: Double, _ lon: Double) -> String {
        return "\(floor(lon)),\(floor(lat)),\(ceil(lon)),\(ceil(lat))"
    }
}
