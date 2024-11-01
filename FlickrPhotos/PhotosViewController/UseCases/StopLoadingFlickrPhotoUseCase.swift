//
//  StopLoadingFlickrPhotoUseCase.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import Foundation
import NetworkAPI

protocol StopLoadingFlickrPhotoUseCase {
    func execute(for url: URL)
}
struct CancelLoadingFlickrPhotoUseCase<ILoader>: StopLoadingFlickrPhotoUseCase where ILoader: ImageLoader {
    private let loader: ILoader
    
    init(loader: ILoader) {
        self.loader = loader
    }
    
    func execute(for url: URL) {
        loader.stopRequest(forURL: url)
    }
}
