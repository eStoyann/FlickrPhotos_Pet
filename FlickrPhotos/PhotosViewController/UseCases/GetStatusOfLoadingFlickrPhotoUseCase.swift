//
//  GetStatusOfLoadingFlickrPhotoUseCase.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import Foundation
import NetworkAPI

protocol GetStatusOfLoadingFlickrPhotoUseCase {
    func execute(for url: URL) -> Bool
}
struct RetrieveStatusOfLoadingFlickrPhotoUseCase<ILoader>: GetStatusOfLoadingFlickrPhotoUseCase where ILoader: ImageLoader {
    private let loader: ILoader
    
    init(loader: ILoader) {
        self.loader = loader
    }
    
    func execute(for url: URL) -> Bool {
        loader.isActiveRequest(forURL: url)
    }
}
