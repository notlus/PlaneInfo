//
//  LookupAircraftOp.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 11/2/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import Foundation

/// Uses the DBPedia "lookup" API to search for a given search term. The result of the operation is
/// an array of `DBPediaLookupResult` objects in the `results` property.
class LookupAircraftOp: Operation {
    
    struct LookupAPIConstants {
        static let BASE_URL = "http://lookup.dbpedia.org/api/search/KeywordSearch"
        static let MAXHITS = "MaxHits"
        static let FORMAT = "json"
        static let QUERY_CLASS = "QueryClass"
    }

    var results = [DBPediaLookupResult]()
    var error: NSError?
    
    private lazy var sharedSession = {
        NSURLSession.sharedSession()
    }()
    
    private var task: NSURLSessionTask?
    private let path = LookupAPIConstants.BASE_URL
    private let searchTerm: String

    
    init(searchTerm: String ) {
        self.searchTerm = searchTerm
        super.init()
    }
    
    override func execute() {
        if cancelled {
            finish()
            return
        }
        
        let methodArguments = [
            LookupAPIConstants.QUERY_CLASS: "thing",
            "QueryString": searchTerm,
            LookupAPIConstants.MAXHITS: "1000"
        ]
        
        let url = createURL(path, withArguments: methodArguments)

        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        self.task = sharedSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let error = error {
                print("Got error \(error)")
                self.error = error
                return
            }
            
            guard let data = data else {
                print("No data in response")
                self.error = NSError(domain: "com.notlus.lop.lookup", code: -1, userInfo: nil)
                return
            }
            
            var jsonResults: [AnyObject]?
            
            do {
                if let rootResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject] {
                    guard let resultsArray = rootResult[DBDownloader.DataConstants.RESULTS_KEY] as? [AnyObject] else {
                        fatalError("Failed to get key: \(DBDownloader.DataConstants.RESULTS_KEY)")
                    }
                    
                    // Filter all of the top level objects and remove any elements that are not
                    // of the class "http://dbpedia.org/ontology/Aircraft"
                    jsonResults = resultsArray.filter({ (element) -> Bool in
                        guard let classes = self.getClasses(element as! [String: AnyObject]) else {
                            return false;
                        }
                        
                        for c in classes {
                            let uri = c["uri"]! as String
                            if uri == DBDownloader.DataConstants.AIRCRAFT_CLASS {
                                return true
                            }
                        }
                        
                        return false
                    })
                    
                    guard let jsonResults = jsonResults else {
                        print("No filtered results found")
                        return
                    }
                    
                    print("Found \(jsonResults.count) aircraft")
                    
                    // Create an array of `DBPedialLookupResult` object from the JSON results.
                    self.results = jsonResults.map({ rawElement -> DBPediaLookupResult in
                        let elementDict = rawElement as! [String: AnyObject]
                        return DBPediaLookupResult(resourceURI: elementDict["uri"] as! String,
                            label: elementDict["label"] as! String,
                            abstract: elementDict["description"] as! String,
                            categories: [String: AnyObject]())
                    })
                }
            } catch let err as NSError {
                print("Failed to create JSON object, error=\(error)")
                self.error = err
            }
            
            self.finish()
        }
        
        task!.resume()
    }
    
    private func createURL(baseURL: String, withArguments arguments: [String: String]) -> NSURL {
        var methodString = String()
        for (key, value) in arguments {
            methodString += methodString.isEmpty ? "?" + key + "=" + value : "&" + key + "=" + value
        }
        
        let fullURL = baseURL + methodString
        return NSURL(string: fullURL)!
    }

    /// Get a map of `classes` for a DBPedia lookup request
    private func getClasses(object: [String: AnyObject]) -> [[String: String]]? {
        return object["classes"] as? [[String: String]]
    }
}
