//
//  PhotosNetworkLoadManagerTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import XCTest
@testable import FlickrPhotos

final class PhotosNetworkLoadManagerTest: XCTestCase {
    private let page = Page(number: 1, size: 10)
    private let searchTerm = "cat"
    private let timeout: TimeInterval = 5
    
    func test_getRecentPhotos_shouldReturnPhotosResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.success)
        sut.getRecentPhotos(byPage: page) {[weak self] result in
            self?.successPhotosResponse(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnResponseFailureError() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.failure(.responseFailure))
        sut.getRecentPhotos(byPage: page) {[weak self] result in
            self?.responseFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnDecodedFailureResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodedFailureResponse))
        sut.getRecentPhotos(byPage: page) {[weak self] result in
            self?.decodedFailureResponse(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnDecodeFailureError() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodingFailure))
        sut.getRecentPhotos(byPage: page) {[weak self] result in
            self?.decodeFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_searchPhotos_shouldReturnPhotosResponseWithSearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.success)
        sut.searchPhoto(bySearchTerm: searchTerm, page: page) {[weak self] result in
            self?.successPhotosResponse(searchTerm: self?.searchTerm, result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnResponseFailureError() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.failure(.responseFailure))
        sut.searchPhoto(bySearchTerm: searchTerm, page: page) {[weak self] result in
            self?.responseFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnDecodedFailureResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodedFailureResponse))
        sut.searchPhoto(bySearchTerm: searchTerm, page: page) {[weak self] result in
            self?.decodedFailureResponse(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnDecodeFailureError() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodingFailure))
        sut.searchPhoto(bySearchTerm: searchTerm, page: page) {[weak self] result in
            self?.decodeFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldFinishFailureCauseOfEmptySearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.success)
        sut.searchPhoto(bySearchTerm: "", page: page) { result in
            if case .failure = result {
            } else {
                XCTFail("Should finish with error")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnPhotosResponseWithSearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.success)
        sut.loadNextPhotosPage(bySearchTerm: searchTerm, page: page) {[weak self] result in
            self?.successPhotosResponse(searchTerm: self?.searchTerm, result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnPhotosResponseWithoutSearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.success)
        sut.loadNextPhotosPage(bySearchTerm: nil, page: page) {[weak self] result in
            self?.successPhotosResponse(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnResponseFailureError() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.failure(.responseFailure))
        sut.loadNextPhotosPage(bySearchTerm: searchTerm, page: page) {[weak self] result in
            self?.responseFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnDecodedFailureResponse() {
        let expectation = expectation(description: "Method \(#function) should return decoded Failure response.")
        
        let sut = sut(.failure(.decodedFailureResponse))
        sut.loadNextPhotosPage(bySearchTerm: searchTerm, page: page) {[weak self] result in
            self?.decodedFailureResponse(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnDecodeFailureError() {
        let expectation = expectation(description: "Method \(#function) should return decodeFailure error.")
        
        let sut = sut(.failure(.decodingFailure))
        sut.loadNextPhotosPage(bySearchTerm: searchTerm, page: page) {[weak self] result in
            self?.decodeFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
}
private extension PhotosNetworkLoadManagerTest {
    func sut(_ options: MockPhotosLoadHTTPClient.Status) -> PhotosNetworkManager {
        let mock = MockPhotosLoadHTTPClient(status: options)
        return PhotosNetworkManager(client: mock)
    }
    func decodeFailureError(_ result: HTTPResult<PhotosResponse>) {
        switch result {
        case .success:
            XCTFail("Should finish with error")
        case let .failure(error):
            XCTAssertNotNil(error is DecodingError)
        case .cancelled:
            XCTFail("Should have cancelled")
        }
        XCTAssertTrue(Thread.isMainThread)
    }
    func decodedFailureResponse(_ result: HTTPResult<PhotosResponse>) {
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
    }
    func responseFailureError(_ result: HTTPResult<PhotosResponse>) {
        if case .failure = result {
        } else {
            XCTFail("Should have failed")
        }
        XCTAssertTrue(Thread.isMainThread)
    }
    func successPhotosResponse(searchTerm: String? = nil,
                               _ result: HTTPResult<PhotosResponse>) {
        switch result {
        case let .success(response):
            if searchTerm != nil {
                XCTAssertNotNil(response.searchTerm)
            }
            XCTAssertTrue(response.searchTerm == searchTerm)
            XCTAssertTrue(response.pageInfo.page.number == page.number)
            XCTAssertTrue(response.pageInfo.page.size == page.size)
            XCTAssertTrue(response.pageInfo.totalPhotos == 10000)
        case .failure:
            XCTFail("Should have finished successfully")
        case .cancelled:
            XCTFail("Should have cancelled")
        }
        XCTAssertTrue(Thread.isMainThread)
    }
}
