//
//  AppManager.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 15.08.2024.
//
import Foundation
import UIKit
import NetworkAPI

final class AppManager {
    
    private let window: UIWindow
    
    init(window: UIWindow?) {
        self.window = window ?? UIWindow(frame: UIScreen.main.bounds)
    }
    func presentPhotosViewController() {
        let pageSize = 24
        let cache = ImagesLocalCache()
        let buffer = ImageRequestsBufferProvider<ImageRequest>()
        let imageRequestsManager = ImagesRequestsManager(buffer: buffer, cache: cache)
        let networkManager = FlickrPhotosNetworkManager()
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
        let viewModel = PhotosViewModel(useCases: useCases)
        let photosViewController: PhotosViewController = .loadFromNib()
        photosViewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: photosViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
