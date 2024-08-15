//
//  AppDelegate.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private lazy var appManager = AppManager(window: window)
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appManager.presentPhotosViewController()
        return true
    }
}



final class AppManager {
    
    private let window: UIWindow
    
    init(window: UIWindow?) {
        self.window = window ?? UIWindow(frame: UIScreen.main.bounds)
    }
    func presentPhotosViewController() {
        let cache = ImagesLocalCache(countLimit: 100, totalCostLimit: 1024*1024*100)
        let buffer = ImageRequestsBufferProvider<ImageRequest>()
        let imageLoadingManager = ImagesLoadingManager(buffer: buffer, cache: cache)
        let networkManager = PhotosNetworkManager()
        let storage = PhotosSearchTermsHistoryLocalStorage()
        let viewModel = PhotosViewModel(networkManager: networkManager,
                                        imageRequestsManager: imageLoadingManager,
                                        imageRequestHTTPClient: URLSession.shared,
                                        photosSearchTermsHistoryLocalStorage: storage)
        let photosViewController: PhotosViewController = .loadFromNib()
        photosViewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: photosViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
