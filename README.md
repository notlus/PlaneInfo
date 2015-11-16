## Overview

**Plane Info** is an iOS application that shows you pictures and information about aircraft from around the world. Some of the features are:

	* View information about aircraft by category
    * Download photos from Flickr
	* Save favorites for quick access

This project consists of two parts:

	* Plane Info - The iOS app
	* PlaneDownloader - The OS X command-line tool

## Motivation

Having had a interest in aviation from a young age, I have wanted to have an app that allowed me to view information about different aircraft. A short while back, I enrolled in the the [Udacity iOS Developer Nanodegree](https://www.udacity.com/course/ios-developer-nanodegree--nd003) program and this gave me the opportunity to learn a new skill and create the app that I have thought about for a long time.

## Plane Info

**Plane Info** is an iOS app that presents aircraft information that is stored in Core Data. By default, only a single (optional) thumbnail image for an aircraft is presented, however, additional photos can be downloaded from [Flickr](https://www.flickr.com).

## PlaneDownloader

**PlaneDownloader** is an OS X command-line tool that uses the [DBPedia Lookup](http://lookup.dbpedia.org) to find various aircraft and downloads data about aircraft using [DBPedia](http://wiki.dbpedia.org) and store it in Core Data. It uses some heuristics to find, categorize and gather data about aircraft. 

## Aircaft Data
**Plane Info** uses a pre-populated Core Data store to retrieve information about aircraft categories, data and photos. The store is populated using the **PlaneDownloader** tool. The app also updates the store with new photos that have been downloaded from Flickr and saved by the user.

## Platform Requirements

### Plane Info
Requires Xcode 7.0 or higher to build and supports iOS 8.4 and above.

### PlaneDownloader
Requires Xcode 7.0 or higher to build and OS X 10.10 and above.

## Installation

### Plane Info
To build, open PlaneInfo.xcodeproj in Xcode and choose the "PlaneInfo" scheme and choose "Build" from the "Product" menu. Building this target

### PlaneDownloader
To build, open PlaneInfo.xcodeproj in Xcode and choose the "PlaneDownloader" scheme and choose "Build" from the "Product" menu. This will generate the "PlaneDownloader" command-line tool, which can be run from a terminal window. The tool takes no arguments and will output a file named "PlaneInfo.sqlite" in the "Documents" folder. To update the aircraft data for the **Plane Info** app, the "PlaneInfo.sqlite" created by this tool can be copied into the Xcode resources to replace what is currently there.

Note that before building the path to the "categories.plist" file must be updated. It is currently hardcoded like this: "/Users/user name/development/Udacity/Projects/PlaneInfo/PlaneInfo/Resources/Categories.plist". This will be fixed in a future update.

## Issues
* **PlaneDownloader** is buggy and crashes processing some data.
* The heuristics used to categorize and gather aircraft data are not very good, so the accuracy of some of the categorization is poor.
* The detailed aircraft data is incomplete due to the varying ways that the data is made available in [DBPedia](http://wiki.dbpedia.org).
* As I am far from a designer, the UI needs some help

## Future Plans

* Improve heuristics for aircraft discovery, categorization and data collection
* Add search capability
* Provide more photos with the app
* Allow searching additional locations for photos
* Additional categories
