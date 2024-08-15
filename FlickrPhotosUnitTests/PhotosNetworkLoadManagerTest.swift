//
//  PhotosNetworkLoadManagerTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import XCTest
@testable import FlickrPhotos

final class PhotosNetworkLoadManagerTest: XCTestCase {
    
    private let page = 1
    private let pageSize = 10
    private let searchTerm = "cat"
    private let timeout: TimeInterval = 5
    
    func test_getRecentPhotos_shouldReturnPhotosResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.success)
        sut.getRecentPhotos(forPage: page, pageSize: pageSize) {[weak self] result in
            self?.successPhotosResponse(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnResponseFailureError() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.failure(.responseFailure))
        sut.getRecentPhotos(forPage: page, pageSize: pageSize) {[weak self] result in
            self?.responseFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldCancelOperation() {
        let expectation = expectation(description: "Method \(#function) should cancel operation")
        
        let sut = sut(.cancelled)
        sut.getRecentPhotos(forPage: page, pageSize: pageSize) {[weak self] result in
            self?.cancelOperation(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnDecodedFailureResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodedFailureResponse))
        sut.getRecentPhotos(forPage: page, pageSize: pageSize) {[weak self] result in
            self?.decodedFailureResponse(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_getRecentPhotos_shouldReturnDecodeFailureError() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodingFailure))
        sut.getRecentPhotos(forPage: page, pageSize: pageSize) {[weak self] result in
            self?.decodeFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_searchPhotos_shouldReturnPhotosResponseWithSearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.success)
        sut.searchPhoto(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.successPhotosResponse(searchTerm: self?.searchTerm, result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnResponseFailureError() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.failure(.responseFailure))
        sut.searchPhoto(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.responseFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldCancelOperation() {
        let expectation = expectation(description: "Method \(#function) should cancel operation")
        
        let sut = sut(.cancelled)
        sut.searchPhoto(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.cancelOperation(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnDecodedFailureResponse() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodedFailureResponse))
        sut.searchPhoto(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.decodedFailureResponse(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldReturnDecodeFailureError() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.failure(.decodingFailure))
        sut.searchPhoto(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.decodeFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_searchPhotos_shouldFinishFailureCauseOfEmptySearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.success)
        sut.searchPhoto(for: "", page: page, pageSize: pageSize) { result in
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
        sut.loadNextPhotosPage(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.successPhotosResponse(searchTerm: self?.searchTerm, result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnPhotosResponseWithoutSearchTerm() {
        let expectation = expectation(description: "Method \(#function) should return PhotosResponse")
        
        let sut = sut(.success)
        sut.loadNextPhotosPage(for: nil, page: page, pageSize: pageSize) {[weak self] result in
            self?.successPhotosResponse(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnResponseFailureError() {
        let expectation = expectation(description: "Method \(#function) should return error")
        
        let sut = sut(.failure(.responseFailure))
        sut.loadNextPhotosPage(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.responseFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldCancelOperation() {
        let expectation = expectation(description: "Method \(#function) should cancel operation")
        
        let sut = sut(.cancelled)
        sut.loadNextPhotosPage(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.cancelOperation(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnDecodedFailureResponse() {
        let expectation = expectation(description: "Method \(#function) should return decoded Failure response.")
        
        let sut = sut(.failure(.decodedFailureResponse))
        sut.loadNextPhotosPage(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.decodedFailureResponse(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    func test_loadNextPhotosPage_shouldReturnDecodeFailureError() {
        let expectation = expectation(description: "Method \(#function) should return decodeFailure error.")
        
        let sut = sut(.failure(.decodingFailure))
        sut.loadNextPhotosPage(for: searchTerm, page: page, pageSize: pageSize) {[weak self] result in
            self?.decodeFailureError(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
}
private extension PhotosNetworkLoadManagerTest {
    func sut(_ options: MockPhotosLoadHTTPClient.Status) -> PhotosNetworkManager {
        let mock = MockPhotosLoadHTTPClient(options: options)
        return PhotosNetworkManager(client: mock)
    }
    func decodeFailureError(_ result: HTTPResult<PhotosResponse, Error>) {
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
    func decodedFailureResponse(_ result: HTTPResult<PhotosResponse, Error>) {
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
    func responseFailureError(_ result: HTTPResult<PhotosResponse, Error>) {
        if case .failure = result {
        } else {
            XCTFail("Should have failed")
        }
        XCTAssertTrue(Thread.isMainThread)
    }
    func successPhotosResponse(searchTerm: String? = nil,
                               _ result: HTTPResult<PhotosResponse, Error>) {
        switch result {
        case let .success(response):
            if searchTerm != nil {
                XCTAssertNotNil(response.searchTerm)
            }
            XCTAssertTrue(response.searchTerm == searchTerm)
            XCTAssertTrue(response.pageInfo.currentPage == page)
            XCTAssertTrue(response.pageInfo.pageSize == pageSize)
            XCTAssertTrue(response.pageInfo.totalPhotos == 10000)
        case .failure:
            XCTFail("Should have finished successfully")
        case .cancelled:
            XCTFail("Should have cancelled")
        }
        XCTAssertTrue(Thread.isMainThread)
    }
    func cancelOperation(_ result: HTTPResult<PhotosResponse, Error>) {
        if case .cancelled = result {
        } else {
            XCTFail("Should have cancelled")
        }
        XCTAssertTrue(Thread.isMainThread)
    }
}
