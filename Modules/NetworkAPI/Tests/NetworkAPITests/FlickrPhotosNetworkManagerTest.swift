//
//  FlickrPhotosNetworkManagerTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import XCTest
import SimpleNetworkKit
import DomainModels
@testable import NetworkAPI

final class FlickrPhotosNetworkManagerTest: XCTestCase {
    private let page = (number: 1, size: 10)
    private let searchTerm = "cat"
    private let timeout: TimeInterval = 5
    
    func test_getRecentPhotos_shouldReturnPhotosResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        let sut = sut(.success)
        
        sut.getRecentPhotos(by: page) {[weak self] result in
            switch result {
            case let .success(response):
                XCTAssertTrue(response.page.current == self?.page.number)
                XCTAssertTrue(response.page.size == self?.page.size)
            case .failure:
                XCTFail("Should have finished successfully")
            case .cancelled:
                XCTFail("Should have cancelled")
            }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnResponseFailureError() {
        let expectation = expectation(description: "Method \(#function) should return error")
        let sut = sut(.failure(.responseFailure))
        
        sut.getRecentPhotos(by: page) { result in
            if case .failure = result {
            } else {
                XCTFail("Should have failed")
            }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnDecodedFailureResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        let sut = sut(.failure(.decodedFailureResponse))
        
        sut.getRecentPhotos(by: page) { result in
            switch result {
            case .success:
                XCTFail("Should finish with error")
            case let .failure(error):
                let failure = error as? Failure
                XCTAssertNotNil(failure)
                XCTAssertTrue(failure?.code == 404)
                XCTAssertTrue(failure?.message == "Failure response")
                XCTAssertTrue(failure?.stat == "bad")
            case .cancelled:
                XCTFail("Should have cancelled")
            }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnDecodeFailureError() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodingFailure))
        sut.getRecentPhotos(by: page) { result in
            switch result {
            case .success:
                XCTFail("Should finish with error")
            case let .failure(error):
                XCTAssertNotNil(error is DecodingError)
            case .cancelled:
                XCTFail("Should have cancelled")
            }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_searchPhotos_shouldReturnPhotosResponseWithSearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.success)
        sut.searchPhoto(by: searchTerm, for: page) {[weak self] result in
            switch result {
            case let .success(response):
                XCTAssertTrue(response.page.current == self?.page.number)
                XCTAssertTrue(response.page.size == self?.page.size)
                XCTAssertTrue(response.page.totalPhotos == 10000)
            case .failure:
                XCTFail("Should have finished successfully")
            case .cancelled:
                XCTFail("Should have cancelled")
            }
            XCTAssertTrue(Thread.isMainThread)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnResponseFailureError() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.failure(.responseFailure))
        sut.searchPhoto(by: searchTerm, for: page) { result in
            if case .failure = result {
            } else {
                XCTFail("Should have failed")
            }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnDecodedFailureResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodedFailureResponse))
        sut.searchPhoto(by: searchTerm, for: page) {result in
            switch result {
            case .success:
                XCTFail("Should finish with error")
            case let .failure(error):
                let failure = error as? Failure
                XCTAssertNotNil(failure)
                XCTAssertTrue(failure?.code == 404)
                XCTAssertTrue(failure?.message == "Failure response")
                XCTAssertTrue(failure?.stat == "bad")
            case .cancelled:
                XCTFail("Should have cancelled")
            }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnDecodeFailureError() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodingFailure))
        sut.searchPhoto(by: searchTerm, for: page) { result in
            switch result {
            case .success:
                XCTFail("Should finish with error")
            case let .failure(error):
                XCTAssertNotNil(error is DecodingError)
            case .cancelled:
                XCTFail("Should have cancelled")
            }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldFinishFailureCauseOfEmptySearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.success)
        sut.searchPhoto(by: "", for: page) { result in
            if case .failure = result {
            } else {
                XCTFail("Should finish with error")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)
    }
}
private extension FlickrPhotosNetworkManagerTest {
    func sut(_ options: MockFlickrPhotosHTTPClient.Status) -> FlickrPhotosNetworkManager {
        let mock = MockFlickrPhotosHTTPClient(status: options)
        return FlickrPhotosNetworkManager(client: mock)
    }
}
