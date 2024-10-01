//
//  PhotosViewModelTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import XCTest
@testable import FlickrPhotos

/*
 func naming: test_subjectName_valueOrFunctionName_expectation
 
 GWT: given, when, then
 */

final class PhotosViewModelTest: XCTestCase {
    
    func test_title_shouldNotBeEmpty() {
        let sut = sut(options: .success)
        
        XCTAssertTrue(sut.title.isNotEmpty, "title should not be empty")
    }
    func test_searchBarPlaceholder_shouldNotBeEmpty() {
        let sut = sut(options: .success)
        
        XCTAssertTrue(sut.searchBarPlaceholder.isNotEmpty, "searchBarPlaceholder should not be empty")
    }
    func test_getPhotosMethod_recentPhotosStateShouldBeLoading() {
        let sut = sut(options: .success)
        
        sut.getPhotos()
        XCTAssertEqual(sut.recentPhotosState.value, .loading, "Value of recentPhotosState property should be loading")
    }
    func test_getPhotosMethod_recentPhotosStateShouldNotFinishFailure() {
        let expectation = expectation(description: "wait for getPhotosMethod finish")
        expectation.expectedFulfillmentCount = 2
        let sut = sut(options: .success)
        
        sut.getPhotos()
        sut.recentPhotosState.bind { state in
            XCTAssertNotEqual(state, .failure(NSError()))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func test_getPhotosMethod_shouldFinishSuccessfully() {
        let expectation = expectation(description: "wait for getPhotosMethod finish successfully")
        expectation.expectedFulfillmentCount = 2
        let sut = sut(options: .success)
        
        sut.getPhotos()
        sut.recentPhotosState.bind { _ in
            XCTAssertGreaterThan(sut.numberOfPhotos(in: 0), 0, "numberOfPhotos should be grater than 0")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    func test_getPhotosMethod_shouldFinishFailure() {
        //given
        let expectation = expectation(description: "wait for getPhotosMethod fail")
        expectation.expectedFulfillmentCount = 2
        let sut = sut(options: .failure(.responseFailure))
        //when
        sut.getPhotos()
        //then
        sut.recentPhotosState.bind { state in
            XCTAssertNotEqual(state, .loaded(true))
            XCTAssertEqual(sut.numberOfPhotos(in: 0), 0, "numberOfPhotos should be 0")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    func test_searchPhotosMethod_recentPhotosStateShouldEqualLoading() {
        let searchTerm = "cat"
        let sut = sut(options: .success)
        
        sut.search(for: searchTerm)
        
        XCTAssertEqual(sut.recentPhotosState.value, .loading, "should have loading state")
    }
    func test_searchPhotosMethod_recentPhotosStateShouldNotBeEqualFailureState() {
        let searchTerm = "cat"
        let sut = sut(options: .success)
        
        sut.search(for: searchTerm)
        
        XCTAssertNotEqual(sut.recentPhotosState.value, .failure(NSError()), "should not be equal failure state")
    }
    
    func test_searchPhotosMethod_numberOfPhotosShouldBeGreaterThanZero() {
        let expectation = expectation(description: "wait for searchPhotosMethod finish successfully")
        expectation.expectedFulfillmentCount = 2
        let searchTerm = "cat"
        let sut = sut(options: .success)
        
        sut.search(for: searchTerm)
        sut.recentPhotosState.bind { state in
            XCTAssertGreaterThan(sut.numberOfPhotos(in: 0), 0, "numberOfPhotos should be grater than 0")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    func test_searchMethod_shouldFinishFailure() {
        let expectation = expectation(description: "wait for searchMethod fail")
        expectation.expectedFulfillmentCount = 2
        let searchTerm = "cat"
        let sut = sut(options: .failure(.responseFailure))
        
        sut.search(for: searchTerm)
        sut.recentPhotosState.bind { state in
            XCTAssertNotEqual(state, .loaded(true))
            XCTAssertEqual(sut.numberOfPhotos(in: 0), 0, "numberOfPhotos should be 0")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    func test_searchMethod_shouldNotBeCalled() {
        let sut = sut(options: .success)
        
        sut.search(for: "")
        
        XCTAssertEqual(sut.recentPhotosState.value, .idle, "recentPhotosState should be idle")
        XCTAssertNil(sut.selectedSearchTerm.value, "selectedSearchTerm should be nil")
    }
    func test_cleanSelectedSearchTermMethod_shouldCleanSelectedSearchTermAndCallGetPhotos() {
        let sut = sut(options: .success)
        
        sut.selectedSearchTerm.value = "cat"
        sut.cleanSelectedSearchTerm()
        
        XCTAssertEqual(sut.recentPhotosState.value, .loading, "Value of recentPhotosState property should be loading")
        XCTAssertNil(sut.selectedSearchTerm.value, "selectedSearchTerm should be nil")
    }
    func test_cleanSelectedSearchTermMethod_shouldCleanSelectedSearchTerm() {
        let sut = sut(options: .success)
        
        sut.cleanSelectedSearchTerm()
        
        XCTAssertEqual(sut.recentPhotosState.value, .idle, "Value of recentPhotosState property should be idle")
        XCTAssertNil(sut.selectedSearchTerm.value, "selectedSearchTerm should be nil")
    }
    func test_loadNextPhotosPageMethod_shouldNotBeCalledCauseOfIsLoadingNextPagePhotosAndUnavailableNextPagePhotos() {
        let sut = sut(options: .success)
        
        sut.loadNextPhotosPage()
        
        XCTAssertEqual(sut.nextPagePhotosState.value, .idle, "nextPagePhotosState should be idle")
    }
    func test_loadNextPhotosPageMethod_shouldBeCalled() {
        let expectation = expectation(description: "wait for loadNextPhotosPageMethod cancel")
        expectation.expectedFulfillmentCount = 3
        let sut = sut(options: .success)
        
        sut.nextPagePhotosState.bind { state in
            XCTAssertNotEqual(state, .failure(NSError()), "shouldn't be equal failure state")
            expectation.fulfill()
        }
        sut.getPhotos()
        sut.recentPhotosState.bind { state in
            if case .loaded = state {
                sut.loadNextPhotosPage()
            }
        }
        waitForExpectations(timeout: 5)
    }
}
private extension PhotosViewModelTest {
    func sut(options: MockPhotosLoadHTTPClient.Status) -> PhotosViewModel<ImagesRequestsManager<ImageRequestsBufferProvider<ImageRequest>, ImagesLocalCache, ImageRequest>, ImageRequest> {
        
        let mockHTTPClient = MockPhotosLoadHTTPClient(status: options)
        let nm = PhotosNetworkManager(client: mockHTTPClient)
        
        let buffer = ImageRequestsBufferProvider<ImageRequest>()
        let cache = ImagesLocalCache(countLimit: 100, totalCostLimit: 1024*1024*100)
        let irm = ImagesRequestsManager(buffer: buffer, cache: cache)
        
        let ls = PhotosSearchTermsHistoryLocalStorage()
        
        return PhotosViewModel(networkManager: nm,
                               imageRequestsManager: irm, 
                               imageRequestHTTPClient: URLSession.shared,
                               photosSearchTermsHistoryLocalStorage: ls)
    }
}





