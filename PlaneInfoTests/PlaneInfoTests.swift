//
//  PlaneInfoTests.swift
//  PlaneInfoTests
//
//  Created by Jeffrey Sulton on 10/1/15.
//  Copyright © 2015 notluS. All rights reserved.
//

import XCTest
@testable import PlaneInfo

class PlaneInfoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSuccessfulDownload() {
        let expectation = self.expectationWithDescription("Successful search for images")
        
        FlickrClient.sharedInstance.downloadImagesForSearchTerm("F-35 Lightning") { (photos, error) -> () in
            XCTAssertNotNil(photos, "photos should not be nil")
            XCTAssert(photos?.isEmpty == false)
            XCTAssertNil(error, "error should be nil")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }

    func testFailedDownload() {
        let expectation = self.expectationWithDescription("Unsuccessful search for images")
        
        FlickrClient.sharedInstance.downloadImagesForSearchTerm("saldfkj") { (photos, error) -> () in
            XCTAssertNil(photos, "photos should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
/*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
*/
}
