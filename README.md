## Overview

**Plane Info** is an iOS application that shows you pictures and information about aircraft from around the world. 

	* View aircraft by category
	* Save favorites for quick access
	* Download photos from Flickr

This project consists of two parts:

	* Plane Info - The iOS app
	* PlaneDownloader - The OS X command-line tool

## Motivation

Having had a interest in aviation from a young age, I have wanted to have an app that allowed me to view information about different aircraft. A short while back, I enrolled in the the [Udacity iOS Developer Nanodegree](https://www.udacity.com/course/ios-developer-nanodegree--nd003) program and this gave me the opportunity to learn a new skill and create the app that I have thought about for a long time.

## Plane Info

**Plane Info** is an iOS app that presents aircraft information that is stored in Core Data. By default, only a single (optional) thumbnail image for an aircraft is presented, however, additional photos can be downloaded from [Flickr](https://www.flickr.com).

## PlaneDownloader

**PlaneDownloader** is an OS X command-line tool that uses [DBPedia](http://wiki.dbpedia.org) to find and download data about aircraft and store it in Core Data. It uses some heuristics to find and categorize aircraft

## Aircaft Data
**Plane Info** uses a pre-populated Core Data store to retrieve information about aircraft categories, data and photos. The store is populated using the **PlaneDownloader** tool. The app also updates the store with new photos that have been saved by the user.

## Installation

**Plane Info** requires Xcode 7.0 or higher to build and supports iOS 8.0 and above. To build, open PlaneInfo.xcodeproj and choose the "PlaneInfo" target

## Future Plans

* Provide more photos with the app
* Allow searching additional locations for photos
* Additional categories
* Search for aircraft in the app
* Improve heuristics for aircraft discovery, categorization and data collection