//
//  ImagesLoadingManagerTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 25.07.2024.
//

import XCTest
@testable import FlickrPhotos

final class ImagesLoadingManagerTest: XCTestCase {

    func test_runAndCacheResult_shouldFinishSuccessfullyOnMainThread() {
        let url = URL(string: "http://test")!
        let sut = sut()
        let expectation = expectation(description: "wait for runAndCacheResult finish successfully")
        
        sut.load(request(url), receiveOn: .main) { image in
            XCTAssertNotNil(image, "image should not be nil")
            XCTAssertTrue(Thread.isMainThread, "Thread.isMainThread should be true")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    func test_runAndCacheResult_shouldFailOnMainThread() {
        let url = URL(string: "http://test")!
        let sut = sut()
        let expectation = expectation(description: "wait for runAndCacheResult fails")
        
        sut.load(request(url, status: .failure), receiveOn: .main) { image in
            XCTAssertNil(image, "image should be nil")
            XCTAssertTrue(Thread.isMainThread, "Thread.isMainThread should be true")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    func test_runAndCacheResult_shouldBeActiveAfterRun() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        sut.load(request(url), receiveOn: .main) {_ in}

        XCTAssertTrue(sut.isActiveRequest(forURL: url), "isActiveRequest should return true")
    }
    func test_setCacheImage_runAndCacheResult_shouldReturnCachedResultOnMainThread() {
        let expectation = expectation(description: "wait for runAndCacheResult return cached image")
        let url = URL(string: "http://test")!
        let buffer = ImageRequestsBufferProvider<ImageRequest>()
        let cache = ImagesLocalCache(countLimit: 100, totalCostLimit: 1024*1024*100)
        let sut = ImagesRequestsManager(buffer: buffer, cache: cache)
        
        cache.set(.placeholder, forURL: url)
        
        sut.load(request(url, status: .failure), receiveOn: .main) { image in
            XCTAssertNotNil(image, "image should not be nil")
            XCTAssertTrue(Thread.isMainThread, "Thread.isMainThread should be true")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    func test_runAndCacheResult_stopRequest_isActiveRequest_shouldReturnFalse() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        sut.load(request(url), receiveOn: .main) {_ in}
        sut.stopRequest(forURL: url)
        
        XCTAssertFalse(sut.isActiveRequest(forURL: url), "isActiveRequest should return false")
    }
    func test_runAndCacheResult_stopAllRequests_bufferCount_shouldBeEqualToZero() {
        let sut = sut()
        
        let url = URL(string: "http://test")!
        sut.load(request(url), receiveOn: .main) {_ in}
        sut.stopAllRequests()
        
        XCTAssertEqual(sut.bufferRequestsCount, 0, "bufferRequestsCount should be equal to zero")
    }
    func test_runAndCacheResult_bufferCount_shouldBeEqualToZero() {
        let expectation = expectation(description: "wait for runAndCacheResult finishes")
        let sut = sut()
        
        let group = DispatchGroup()
        
        for i in 1...10 {
            group.enter()
            let url = URL(string: "http://test\(i)")!
            sut.load(request(url), receiveOn: .main) {_ in
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            XCTAssertEqual(sut.bufferRequestsCount, 0, "bufferRequestsCount should be equal to zero")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    func test_runAndCacheResult_bufferCount_shouldBeEqualTo3() {
        let sut = sut()
        
        for i in 1...3 {
            let url = URL(string: "http://test\(i)")!
            sut.load(request(url), receiveOn: .main) {_ in}
        }
        
        XCTAssertEqual(sut.bufferRequestsCount, 3, "bufferRequestsCount should be equal to ten")
    }
    func test_runAndCacheResult_cacheCount_shouldBeEqualTo3() {
        let expectation = expectation(description: "wait for runAndCacheResult finishes")
        let sut = sut()
        
        let group = DispatchGroup()
        
        for i in 1...3 {
            group.enter()
            let url = URL(string: "http://test\(i)")!
            sut.load(request(url), receiveOn: .main) {_ in
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            XCTAssertEqual(sut.cachedImagesCount, 3, "cachedImagesCount should be equal to 3")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    func test_runAndCacheResult_cacheCount_shouldBeEqualToZero() {
        let expectation = expectation(description: "wait for runAndCacheResult finishes")
        let sut = sut()
        
        let group = DispatchGroup()
        
        for i in 1...3 {
            group.enter()
            let url = URL(string: "http://test\(i)")!
            sut.load(request(url, status: .failure), receiveOn: .main) {_ in
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            XCTAssertEqual(sut.cachedImagesCount, 0, "cachedImagesCount should be equal to zero")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    func test_cleanCachedData_cacheCount_shouldBeEqualToZero() {
        let expectation = expectation(description: "wait for runAndCacheResult finishes")
        let sut = sut()
        
        let group = DispatchGroup()
        
        for i in 1...3 {
            group.enter()
            let url = URL(string: "http://test\(i)")!
            sut.load(request(url, status: .success), receiveOn: .main) {_ in
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            sut.cleanCachedData()
            XCTAssertEqual(sut.cachedImagesCount, 0, "cachedImagesCount should be equal to zero")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
}
private extension ImagesLoadingManagerTest {
    func sut() -> ImagesRequestsManager<ImageRequestsBufferProvider<ImageRequest>, ImagesLocalCache, ImageRequest> {
        let buffer = ImageRequestsBufferProvider<ImageRequest>()
        let cache = ImagesLocalCache(countLimit: 100, totalCostLimit: 1024*1024*100)
        return ImagesRequestsManager(buffer: buffer, cache: cache)
    }
    func request(_ url: URL, status: MockImageRequestHTTPClient.Status = .success) -> ImageRequest {
        let mockClient = MockImageRequestHTTPClient(status: status)
        return ImageRequest(url: url, timeout: 15, client: mockClient)
    }
}
