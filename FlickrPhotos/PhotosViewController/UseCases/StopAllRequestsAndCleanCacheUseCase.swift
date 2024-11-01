//
//  StopAllRequestsAndCleanCacheUseCase.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import SimpleNetworkKit
import DomainModels
import NetworkAPI

protocol StopAllRequestsAndCleanCacheUseCase {
    func execute()
}
struct CancelAllRequestsAndCleanCacheUseCase<ILoader>: StopAllRequestsAndCleanCacheUseCase where ILoader: ImageLoader {
    private let loader: ILoader
    
    init(loader: ILoader) {
        self.loader = loader
    }
    
    func execute() {
        loader.stopAllRequests()
        loader.cleanCachedData()
    }
}
