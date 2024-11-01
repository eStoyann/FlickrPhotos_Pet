//
//  ImageRequestTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 24.07.2024.
//

import XCTest
@testable import NetworkAPI

final class ImageRequestTest: XCTestCase {

    func test_run_shouldBeFinishedSuccessfully() {
        //given
        let url = URL(string: "http://test")!
        let mock = MockImageRequestHTTPClient(status: .success)
        let sut = ImageRequest(url: url, timeout: 15, client: mock)
        let expectation = expectation(description: "wait for image")
        //when
        sut.start { image in
            XCTAssertNotNil(image)
            expectation.fulfill()
        }
        //then
        waitForExpectations(timeout: 5)
    }
    func test_run_shouldBeFail() {
        let url = URL(string: "http://test")!
        let mock = MockImageRequestHTTPClient(status: .failure)
        let sut = ImageRequest(url: url, timeout: 15, client: mock)
        let expectation = expectation(description: "wait for error")
        
        sut.start { image in
            XCTAssertNil(image)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    func test_cancel_shouldBeCancelled() {
        let url = URL(string: "http://test")!
        let mock = MockImageRequestHTTPClient(status: .success)
        let sut = ImageRequest(url: url, timeout: 15, client: mock)
        let expectation = expectation(description: "wait for error")
        
        sut.start {_ in
            expectation.fulfill()
        }
        sut.cancel()
        
        XCTAssertTrue(sut.isCancelled)
        waitForExpectations(timeout: 5)
    }
}
