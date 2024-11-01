//
//  SearchFlickrPhotosUseCase.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import DomainModels
import SimpleNetworkKit
import NetworkAPI

protocol SearchFlickrPhotosUseCase {
    func execute(by searchText: String,
                 _ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void)
}
struct FindFlickrPhotosUseCase<ILoader>: SearchFlickrPhotosUseCase where ILoader: ImageLoader {
    private let repo: FlickrPhotosRepository
    private let pageSize: Int
    private let loader: ILoader
    
    init(repo: FlickrPhotosRepository,
         loader: ILoader,
         pageSize: Int) {
        self.repo = repo
        self.loader = loader
        self.pageSize = pageSize
    }
    
    func execute(by searchText: String,
                 _ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void) {
        loader.stopAllRequests()
        loader.cleanCachedData()
        repo.searchPhotos(by: searchText,
                          for: (1, pageSize),
                          finished)
    }
}

