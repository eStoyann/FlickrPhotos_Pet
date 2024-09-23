//
//  AppManager.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 15.08.2024.
//

import Foundation
import UIKit

final class AppManager {
    
    private let window: UIWindow
    
    init(window: UIWindow?) {
        self.window = window ?? UIWindow(frame: UIScreen.main.bounds)
    }
    func presentPhotosViewController() {
        let cache = ImagesLocalCache()
        let buffer = ImageRequestsBufferProvider<ImageRequest>()
        let imageRequestsManager = ImagesRequestsManager(buffer: buffer, cache: cache)
        let networkManager = PhotosNetworkManager()
        let storage = PhotosSearchTermsHistoryLocalStorage()
        let viewModel = PhotosViewModel(networkManager: networkManager,
                                        imageRequestsManager: imageRequestsManager,
                                        imageRequestHTTPClient: URLSession.shared,
                                        photosSearchTermsHistoryLocalStorage: storage)
        let photosViewController: PhotosViewController = .loadFromNib()
        photosViewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: photosViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
