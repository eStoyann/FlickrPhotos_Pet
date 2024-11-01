//
//  LoadFlickrPhotoUseCase.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import NetworkAPI
import Foundation
import UIKit

protocol StartLoadingFlickrPhotoUseCase {
    func execute(for url: URL,
                 _ finished: @escaping @Sendable (UIImage?) -> Void)
}
struct GetFlickrPhotoUseCase<ILoader, IRequest>: StartLoadingFlickrPhotoUseCase where ILoader: ImageLoader, IRequest == ILoader.Request {
    private let loader: ILoader
    
    init(loader: ILoader) {
        self.loader = loader
    }
    
    func execute(for url: URL,
                 _ finished: @escaping @Sendable (UIImage?) -> Void) {
        let request = IRequest(url: url)
        loader.load(request, receiveOn: .main, finished)
    }
}




