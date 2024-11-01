//
//  FlickrPhotosRepository.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import NetworkAPI
import SimpleNetworkKit
import DomainModels

protocol FlickrPhotosRepository {
    typealias Page = (number: Int, size: Int)
    func fetchRecentPhotos(for page: Page,
                           _ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void)
    func searchPhotos(by term: String,
                      for page: Page,
                      _ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void)
}
struct FlickrPhotosRepo: FlickrPhotosRepository {
    let service: FlickrPhotosNetworkService
    
    init(service: FlickrPhotosNetworkService) {
        self.service = service
    }
    
    func fetchRecentPhotos(for page: Page,
                           _ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void) {
        service.getRecentPhotos(by: page, finished)
    }
    func searchPhotos(by term: String,
                      for page: Page,
                      _ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void) {
        service.searchPhoto(by: term, for: page, finished)
    }
}
