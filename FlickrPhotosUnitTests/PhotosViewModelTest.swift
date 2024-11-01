//
//  PhotosViewModelTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import XCTest
import NetworkAPI
@testable import FlickrPhotos

/*
 func naming: test_subjectName_valueOrFunctionName_expectation
 
 GWT: given, when, then
 */

final class PhotosViewModelTest: XCTestCase {
    
    func test_title_shouldNotBeEmpty() {
        let sut = sut(status: .success)
        
        XCTAssertTrue(sut.title.isNotEmpty, "title should not be empty")
    }
    func test_searchBarPlaceholder_shouldNotBeEmpty() {
        let sut = sut(status: .success)
        
        XCTAssertTrue(sut.searchBarPlaceholder.isNotEmpty, "searchBarPlaceholder should not be empty")
    }
    func test_getPhotosMethod_recentPhotosStateShouldBeLoading() {
        let sut = sut(status: .success)
        
        sut.getPhotos()
        XCTAssertEqual(sut.loadRecentPhotosOperationStatus.value, .performing, "Value of loadRecentPhotosOperationStatus property should be loading")
    }
    func test_getPhotosMethod_recentPhotosStateShouldNotFinishFailure() {
        let expectation = expectation(description: "wait for getPhotosMethod finish")
        expectation.expectedFulfillmentCount = 2
        let sut = sut(status: .success)
        
        sut.getPhotos()
        sut.loadRecentPhotosOperationStatus.bind { state in
            XCTAssertNotEqual(state, .failed(NSError()))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func test_getPhotosMethod_shouldFinishSuccessfully() {
        let expectation = expectation(description: "wait for getPhotosMethod finish successfully")
        expectation.expectedFulfillmentCount = 2
        let sut = sut(status: .success)
        
        sut.getPhotos()
        sut.loadRecentPhotosOperationStatus.bind { _ in
            XCTAssertGreaterThan(sut.numberOfPhotos(in: 0), 0, "numberOfPhotos should be grater than 0")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    func test_getPhotosMethod_shouldFinishFailure() {
        //given
        let expectation = expectation(description: "wait for getPhotosMethod fail")
        expectation.expectedFulfillmentCount = 2
        let sut = sut(status: .failure(.responseFailure))
        //when
        sut.getPhotos()
        //then
        sut.loadRecentPhotosOperationStatus.bind { state in
            XCTAssertNotEqual(state, .performed(true))
            XCTAssertEqual(sut.numberOfPhotos(in: 0), 0, "numberOfPhotos should be 0")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    func test_searchPhotosMethod_recentPhotosStateShouldEqualLoading() {
        let searchTerm = "cat"
        let sut = sut(status: .success)
        
        sut.search(for: searchTerm)
        
        XCTAssertEqual(sut.loadRecentPhotosOperationStatus.value, .performing, "should have loading state")
    }
    func test_searchPhotosMethod_recentPhotosStateShouldNotBeEqualFailureState() {
        let searchTerm = "cat"
        let sut = sut(status: .success)
        
        sut.search(for: searchTerm)
        
        XCTAssertNotEqual(sut.loadRecentPhotosOperationStatus.value, .failed(NSError()), "should not be equal failure state")
    }
    
    func test_searchPhotosMethod_numberOfPhotosShouldBeGreaterThanZero() {
        let expectation = expectation(description: "wait for searchPhotosMethod finish successfully")
        expectation.expectedFulfillmentCount = 2
        let searchTerm = "cat"
        let sut = sut(status: .success)
        
        sut.search(for: searchTerm)
        sut.loadRecentPhotosOperationStatus.bind { state in
            XCTAssertGreaterThan(sut.numberOfPhotos(in: 0), 0, "numberOfPhotos should be grater than 0")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    func test_searchMethod_shouldFinishFailure() {
        let expectation = expectation(description: "wait for searchMethod fail")
        expectation.expectedFulfillmentCount = 2
        let searchTerm = "cat"
        let sut = sut(status: .failure(.responseFailure))
        
        sut.search(for: searchTerm)
        sut.loadRecentPhotosOperationStatus.bind { state in
            XCTAssertNotEqual(state, .performed(true))
            XCTAssertEqual(sut.numberOfPhotos(in: 0), 0, "numberOfPhotos should be 0")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    func test_searchMethod_shouldNotBeCalled() {
        let sut = sut(status: .success)
        
        sut.search(for: "")
        
        XCTAssertEqual(sut.loadRecentPhotosOperationStatus.value, .idle, "loadRecentPhotosOperationStatus should be idle")
        XCTAssertNil(sut.selectedSearchTerm.value, "selectedSearchTerm should be nil")
    }
    func test_cleanSelectedSearchTermMethod_shouldCleanSelectedSearchTermAndCallGetPhotos() {
        let sut = sut(status: .success)
        
        sut.selectedSearchTerm.value = "cat"
        sut.cleanSelectedSearchTerm()
        
        XCTAssertEqual(sut.loadRecentPhotosOperationStatus.value, .performing, "Value of loadRecentPhotosOperationStatus property should be loading")
        XCTAssertNil(sut.selectedSearchTerm.value, "selectedSearchTerm should be nil")
    }
    func test_cleanSelectedSearchTermMethod_shouldCleanSelectedSearchTerm() {
        let sut = sut(status: .success)
        
        sut.cleanSelectedSearchTerm()
        
        XCTAssertEqual(sut.loadRecentPhotosOperationStatus.value, .idle, "Value of loadRecentPhotosOperationStatus property should be idle")
        XCTAssertNil(sut.selectedSearchTerm.value, "selectedSearchTerm should be nil")
    }
    func test_loadNextPhotosPageMethod_shouldNotBeCalledCauseOfIsLoadingNextPagePhotosAndUnavailableNextPagePhotos() {
        let sut = sut(status: .success)
        
        sut.loadNextPhotosPage()
        
        XCTAssertEqual(sut.loadNextPhotosPageOperationStatus.value, .idle, "loadNextPhotosPageOperationStatus should be idle")
    }
    func test_loadNextPhotosPageMethod_shouldBeCalled() {
        let expectation = expectation(description: "wait for loadNextPhotosPageMethod cancel")
        expectation.expectedFulfillmentCount = 3
        let sut = sut(status: .success)
        
        sut.loadNextPhotosPageOperationStatus.bind { state in
            XCTAssertNotEqual(state, .failed(NSError()), "shouldn't be equal failure state")
            expectation.fulfill()
        }
        sut.getPhotos()
        sut.loadRecentPhotosOperationStatus.bind { state in
            if case .performed = state {
                sut.loadNextPhotosPage()
            }
        }
        waitForExpectations(timeout: 5)
    }
}
private extension PhotosViewModelTest {
    func sut(status: MockPhotosLoadHTTPClient.Status) -> PhotosViewModel {
        let pageSize = 24
        let cache = ImagesLocalCache(countLimit: 100, totalCostLimit: 0)
        let buffer = ImageRequestsBufferProvider<ImageRequest>()
        let imageRequestsManager = ImagesRequestsManager(buffer: buffer, cache: cache)
        let mockHTTPClient = MockPhotosLoadHTTPClient(status: status)
        let networkManager = FlickrPhotosNetworkManager(client: mockHTTPClient)
        let storage = SearchTermsHistoryLocalStorage()
        let flickrPhotosRepo = FlickrPhotosRepo(service: networkManager)
        let fetchRecentPhotos = RetrieveRecentFlickrPhotosUseCase(repo: flickrPhotosRepo,
                                                                  pageSize: pageSize)
        let searchPhotos = FindFlickrPhotosUseCase(repo: flickrPhotosRepo,
                                                   loader: imageRequestsManager,
                                                   pageSize: pageSize)
        let fetchNextPhotosPage = RetrieveNextFlickrPhotosPageUseCase(repo: flickrPhotosRepo,
                                                                      pageSize: pageSize)
        let stopAllRequestsAndCleanCache = CancelAllRequestsAndCleanCacheUseCase(loader: imageRequestsManager)
        let startLoadingPhoto = GetFlickrPhotoUseCase(loader: imageRequestsManager)
        let stopLoadingPhoto = CancelLoadingFlickrPhotoUseCase(loader: imageRequestsManager)
        let getStatusOfLoadingPhoto = RetrieveStatusOfLoadingFlickrPhotoUseCase(loader: imageRequestsManager)
        let searchTermsRepo = SearchTermsRepo(storage: storage)
        let storeSearchTerm = SaveSearchTermUseCase(repo: searchTermsRepo)
        let useCases: PhotosViewModel.UseCases = .init(fetchRecentPhotos: fetchRecentPhotos,
                                                               searchPhotos: searchPhotos,
                                                               fetchNextPhotosPage: fetchNextPhotosPage,
                                                               stopAllRequestsAndCleanCache: stopAllRequestsAndCleanCache,
                                                               startLoadingPhoto: startLoadingPhoto,
                                                               stopLoadingPhoto: stopLoadingPhoto,
                                                               getStatusOfLoadingPhoto: getStatusOfLoadingPhoto,
                                                               storeSearchTerm: storeSearchTerm)
        return PhotosViewModel(useCases: useCases)
    }
}
