//
//  HTTPLayerTests.swift
//  HTTPLayerTests
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import XCTest
@testable import HTTPLayer

class HTTPLayerTests: XCTestCase {

    override func setUp() {
        HTTP.config.add(host: "https://jsonplaceholder.typicode.com", withContext: "", onKey: "DEFAULT")
        HTTP.config.add(header: (key: "Content-type", value: "application/json; charset=UTF-8"), onKey: "DEFAULT")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetWithoutParameters() {
        let ex = expectation(description: "Expected server response, but naught was found")
        HTTP.request.get(from: "/posts", withHostAndContext: "DEFAULT", andHeaders: "DEFAULT", receivingObjectType: [GETWithoutParametersResponse].self) { (response) in
            switch response {
            case .success(let success):
                XCTAssertNotNil(success)
            case .failure(let failure):
                XCTFail("Error: \(failure.localizedDescription)")
            }
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            guard let error = error else { return }
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func testGetWithQueryParameters() {
        let ex = expectation(description: "Expected server response, but naught was found")
        HTTP.request.get(from: "/comments", usingQueryParameters: [ "postId" : "1" ], fromHostAndContext: "DEFAULT", andHeaders: "DEFAULT", receivingObjectType: [GETWithQueryParametersResponse].self) { (response) in
            switch response {
            case .success(let success):
                XCTAssertNotNil(success)
            case .failure(let failure):
                XCTFail("Error: \(failure.localizedDescription)")
            }
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            guard let error = error else { return }
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func testGetWithPathParameters() {
        let ex = expectation(description: "Expected server response, but naught was found")
        HTTP.request.get(from: "/posts", usingPathParameters: ["1", "comments"], fromHostAndContext: "DEFAULT", andHeaders: "DEFAULT", receivingObjectType: [GETWithPathParametersResponse].self) { (response) in
            switch response {
            case .success(let success):
                XCTAssertNotNil(success)
            case .failure(let failure):
                XCTFail("Error: \(failure.localizedDescription)")
            }
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            guard let error = error else { return }
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func testPostWithBodyParameter() {
        let ex = expectation(description: "Expected server response, but naught was found")
        let body = POSTWithBodyParameterRequest(title: "foo", body: "bar", userId: 1)
        HTTP.request.post(to: "/posts", withBody: body, fromHostAndContext: "DEFAULT", andHeaders: "DEFAULT", receivingObjectType: POSTWithBodyParameterResponse.self) { (response) in
            switch response {
            case .success(let success):
                XCTAssertNotNil(success)
            case .failure(let failure):
                XCTFail("Error: \(failure.localizedDescription)")
            }
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            guard let error = error else { return }
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    //===================: Test Implemented but without a Service to Consume :==========================
    //
    //    func testPutWithBodyAndQueryParameters() {
    //        let ex = expectation(description: "Expected server response, but naught was found")
    //        let body = PUTWithBodyAndQueryParametersRequest(id: 1, title: "foo", body: "bar", userId: 1)
    //        HTTP.request.put(on: "/posts", withBody: body, andQueryParameters: ["userId": "1"], fromHostAndContext: "DEFAULT", andHeaders: "DEFAULT", receivingObjectType: PUTWithBodyAndQueryParametersResponse.self) { (response) in
    //            switch response {
    //            case .success(let success):
    //                XCTAssertNotNil(success)
    //            case .failure(let failure):
    //                XCTFail("Error: \(failure.localizedDescription)")
    //            }
    //            ex.fulfill()
    //        }
    //
    //        waitForExpectations(timeout: 5) { (error) in
    //            guard let error = error else { return }
    //            XCTFail("Error: \(error.localizedDescription)")
    //        }
    //    }
    //
    //==================================================================================================
    
    func testPutWithBodyAndPathParameters() {
        let ex = expectation(description: "Expected server response, but naught was found")
        let body = PUTWithBodyAndQueryParametersRequest(id: 1, title: "foo", body: "bar", userId: 1)
        HTTP.request.put(on: "/posts", withBody: body, andPathParameters: ["1"], fromHostAndContext: "DEFAULT", andHeaders: "DEFAULT", receivingObjectType: PUTWithBodyAndQueryParametersResponse.self) { (response) in
            switch response {
            case .success(let success):
                XCTAssertNotNil(success)
            case .failure(let failure):
                XCTFail("Error: \(failure.localizedDescription)")
            }
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            guard let error = error else { return }
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func testDeleteWithBodyAndPathParameters() {
        let ex = expectation(description: "Expected server response, but naught was found")
        HTTP.request.delete(from: "posts", withBody: nil, andPathParameters: ["1"], fromHostAndContext: "DEFAULT", andHeaders: "DEFAULT", receivingObjectType: DELETEWithBodyAndPathParametersResponse.self) { (response) in
            switch response {
            case .success(let success):
                XCTAssertNotNil(success)
            case .failure(let failure):
                XCTFail("Error: \(failure.localizedDescription)")
            }
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            guard let error = error else { return }
            XCTFail("Error: \(error.localizedDescription)")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
