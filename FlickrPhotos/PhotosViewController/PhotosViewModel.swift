//
//  PhotosViewModel.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 19.07.2024.
//

import Foundation
import UIKit

protocol PhotosDataSource {
    var numberOfSectionsOfPhotos: Int{get}
    
    func numberOfPhotos(in section: Int) -> Int
    func startLoadingImage(at indexPath: IndexPath, _ finished: @escaping (UIImage?) -> Void)
    func isLoadingImage(at indexPath: IndexPath) -> Bool
    func stopLoadingImage(at indexPath: IndexPath)
    func loadNextPhotosPage()
}
extension PhotosDataSource {
    var numberOfSectionsOfPhotos: Int{1}
}

protocol PhotosViewModelProtocol {
    
    var title: String {get}
    var searchBarPlaceholder: String {get}
    var photosSearchTermsHistoryViewModel: PhotosSearchTermsHistoryViewModel {get}
    var selectedSearchTerm: Publisher<String?>{get}
    var nextPagePhotosState: Publisher<State<Array<IndexPath>>>{get}
    var recentPhotosState: Publisher<State<Bool>>{get}
    
    func getPhotos()
}

protocol PhotosSearchTermsDelegate {
    func search(for searchTerm: String)
    func cleanSelectedSearchTerm()
}

final class PhotosViewModel<IRManager, IRequest>: PhotosViewModelProtocol where IRManager: ImageLoader,
                                                                               IRManager.Request == IRequest {
    
    
    
    //MARK: - Private properties
    private let networkManager: PhotosNetworkService
    private let imageRequestHTTPClient: HTTPClient
    private let imageRequestsManager: IRManager
    private let searchTermsHistoryStorage: PhotosSearchTermsHistoryStorage
    private var photosResponse: PhotosResponse?
    private let pageSize = 24
    
    //MARK: - Public properties
    let selectedSearchTerm = Publisher<String?>(initValue: nil)
    let nextPagePhotosState = Publisher<State<Array<IndexPath>>>(initValue: .idle)
    let recentPhotosState = Publisher<State<Bool>>(initValue: .idle)
    var title: String {
        "Flickr Photos"
    }
    var searchBarPlaceholder: String {
        "Search photos"
    }
    var photosSearchTermsHistoryViewModel: PhotosSearchTermsHistoryViewModel {
        let storage = PhotosSearchTermsHistoryLocalStorage()
        let viewModel = PhotosSearchTermsHistoryViewModel(searchTermsHistoryLocalStorage: storage)
        viewModel.selectedSearchTerm.bind {[weak self] searchTerm in
            guard let self else {return}
            guard let searchTerm else {return}
            if searchTerm != selectedSearchTerm.value {
                search(for: searchTerm)
            } else {
                selectedSearchTerm.value = searchTerm
            }
        }
        return viewModel
    }
    
    //MARK: - Lifecycle
    init(networkManager: PhotosNetworkService,
         imageRequestsManager: IRManager,
         imageRequestHTTPClient: HTTPClient,
         photosSearchTermsHistoryLocalStorage: PhotosSearchTermsHistoryStorage) {
        self.networkManager = networkManager
        self.imageRequestsManager = imageRequestsManager
        self.searchTermsHistoryStorage = photosSearchTermsHistoryLocalStorage
        self.imageRequestHTTPClient = imageRequestHTTPClient
    }
    
    func getPhotos() {
        recentPhotosState.value = .loading
        networkManager.getRecentPhotos(forPage: 1,
                                       pageSize: pageSize,
                                       processResultOfLoadedPhotos)
    }
}
//MARK: - PhotosDataSource
extension PhotosViewModel: PhotosDataSource {
    func numberOfPhotos(in section: Int) -> Int {
        photosResponse?.pageInfo.photos.count ?? 0
    }
    func startLoadingImage(at indexPath: IndexPath, _ finished: @escaping (UIImage?) -> Void) {
        if let url = url(at: indexPath) {
            let imageRequest = IRequest(url: url,
                                        timeout: 60,
                                        client: imageRequestHTTPClient)
            imageRequestsManager.runAndCacheResult(of: imageRequest, receiveOn: .main) { image in
                image?.prepareForDisplay { preparedImage in
                    DispatchQueue.main.async {
                        finished(preparedImage)
                    }
                } ?? finished(nil)
            }
        }
    }
    func isLoadingImage(at indexPath: IndexPath) -> Bool {
        if let url = url(at: indexPath) {
            return imageRequestsManager.isActiveRequest(forURL: url)
        }
        return false
    }
    func stopLoadingImage(at indexPath: IndexPath) {
        if let url = url(at: indexPath) {
            imageRequestsManager.stopRequest(forURL: url)
        }
    }
    func loadNextPhotosPage() {
        if case .idle = nextPagePhotosState.value,
           let nextPage = photosResponse?.pageInfo.nextPage {
            nextPagePhotosState.value = .loading
            networkManager.loadNextPhotosPage(for: selectedSearchTerm.value,
                                              page: nextPage,
                                              pageSize: pageSize,
                                              processResultOfNextLoadedPagePhotos)
        }
    }
}
//MARK: - PhotosSearchTermsDelegate
extension PhotosViewModel: PhotosSearchTermsDelegate {
    func search(for searchTerm: String) {
        guard searchTerm.isNotEmpty else {return}
        selectedSearchTerm.value = searchTerm
        searchTermsHistoryStorage.add(searchTerm: searchTerm)
        if case .idle = recentPhotosState.value {
            recentPhotosState.value = .loading
            imageRequestsManager.stopAllRequests()
            imageRequestsManager.cleanCachedData()
            networkManager.searchPhoto(for: searchTerm,
                                       page: 1,
                                       pageSize: pageSize,
                                       processResultOfLoadedPhotos)
        }
    }
    func cleanSelectedSearchTerm() {
        if selectedSearchTerm.value != nil {
            selectedSearchTerm.value = nil
            imageRequestsManager.stopAllRequests()
            imageRequestsManager.cleanCachedData()
            getPhotos()
        }
    }
}
private extension PhotosViewModel {
    func url(at indexPath: IndexPath) -> URL? {
        if numberOfPhotos(in: indexPath.section) > indexPath.row {
            let photo = photosResponse!.pageInfo.photos[indexPath.row]
            let endpoint = PhotosHTTPRouter.photo(farm: photo.farm,
                                                      server: photo.server,
                                                      id: photo.id,
                                                      secret: photo.secret,
                                                      size: "q").endpoint
            if let url = try? endpoint.request().url {
                return url
            }
        }
        return nil
    }
    func newPagePhotosIndices(of newPageInfo: PhotosResponse.PageInfo) -> Array<IndexPath> {
        guard !newPageInfo.photos.isEmpty else {
            return []
        }
        guard let oldPageInfo = photosResponse?.pageInfo else {
            return newPageInfo.photos.indices.map{IndexPath(row: $0, section: 0)}
        }
        let oldPhotosCount = oldPageInfo.photos.count
        let newPhotosCount = newPageInfo.photos.count
        let resultPhotosCount = oldPhotosCount+newPhotosCount
        return (oldPhotosCount..<resultPhotosCount).map({IndexPath(row: $0, section: 0)})
    }
    func processResultOfNextLoadedPagePhotos(_ result: HTTPResult<PhotosResponse, Error>) {
        weak var weakSelf = self
        guard let self = weakSelf else {return}
        switch result {
        case let .success(response):
            let indices = self.newPagePhotosIndices(of: response.pageInfo)
            self.updatePhotosResponse(byNewOne: response)
            self.nextPagePhotosState.value = .loaded(indices)
        case let .failure(error):
            self.nextPagePhotosState.value = .failure(error)
        case .cancelled:
            break
        }
        self.nextPagePhotosState.value = .idle
    }
    func processResultOfLoadedPhotos(_ result: HTTPResult<PhotosResponse, Error>) {
        weak var weakSelf = self
        guard let self = weakSelf else {return}
        switch result {
        case let .success(response):
            self.photosResponse = response
            self.recentPhotosState.value = .loaded(true)
        case let .failure(error):
            self.recentPhotosState.value = .failure(error)
        case .cancelled:
            break
        }
        self.recentPhotosState.value = .idle
    }
    func updatePhotosResponse(byNewOne response: PhotosResponse) {
        guard let oldPhotosPageInfo = photosResponse?.pageInfo else {
            photosResponse = response
            return
        }
        let photos = oldPhotosPageInfo.photos+response.pageInfo.photos
        let pageInfo = PhotosResponse.PageInfo(currentPage: response.pageInfo.currentPage,
                                               totalPages: response.pageInfo.totalPages,
                                               pageSize: response.pageInfo.pageSize,
                                               totalPhotos: response.pageInfo.totalPhotos,
                                               photos: photos)
        photosResponse = PhotosResponse(pageInfo: pageInfo)
    }
}
