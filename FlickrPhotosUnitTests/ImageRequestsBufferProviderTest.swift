//
//  ImageRequestsBufferProviderTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 24.07.2024.
//

import XCTest
@testable import FlickrPhotos

final class ImageRequestsBufferProviderTest: XCTestCase {

    func test_afterInitBufferShouldBeEmpty() {
        let sut = ImageRequestsBufferProvider<ImageRequest>()
        
        XCTAssertTrue(sut.count == 0)
    }
    func test_add_bufferShouldBeEqualToOne() {
        let request = ImageRequest(url: URL(string: "http://test")!)
        let sut = ImageRequestsBufferProvider<ImageRequest>()
        
        for _ in 1...5 {
            sut.add(request: request)
        }
        XCTAssertEqual(sut.count, 1)
    }
    func test_add_bufferShouldBeEqualToFive() {
        let count = 5
        let sut = ImageRequestsBufferProvider<ImageRequest>()
        
        for i in 1...count {
            let request = ImageRequest(url: URL(string: "http://test\(i)")!)
            sut.add(request: request)
        }
        
        XCTAssertEqual(sut.count, count)
    }
    func test_clean_bufferShouldBeEmptyAfterClean() {
        let sut = ImageRequestsBufferProvider<ImageRequest>()
        
        for i in 1...5 {
            let path = "http://test\(i)"
            let request = ImageRequest(url: URL(string: path)!)
            sut.add(request: request)
        }
        sut.clean()
        
        XCTAssertEqual(sut.count, 0)
    }
    
    func test_remove_bufferShouldBeEmptyAfterRemovingRequest() {
        let request = ImageRequest(url: URL(string: "http://test")!)
        let sut = ImageRequestsBufferProvider<ImageRequest>()
        
        sut.add(request: request)
        sut.remove(request: request)
        
        XCTAssertEqual(sut.count, 0)
    }
    func test_request_shouldReturnRequestForSpecificURL() {
        let request = ImageRequest(url: URL(string: "http://test")!)
        let sut = ImageRequestsBufferProvider<ImageRequest>()
        
        sut.add(request: request)
        let foundRequest = sut.request(forURL: request.url)
        
        XCTAssertNotNil(foundRequest)
    }
    func test_removeRequest_bufferShouldBeEmptyAfterRemovingRequestForSpecificURL() {
        let request = ImageRequest(url: URL(string: "http://test")!)
        let sut = ImageRequestsBufferProvider<ImageRequest>()
        
        sut.add(request: request)
        sut.removeRequest(forURL: request.url)
        
        XCTAssertEqual(sut.count, 0)
    }
}
