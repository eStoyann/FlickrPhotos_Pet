//
//  FetchRecentPhotosUseCase.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import DomainModels
import SimpleNetworkKit

protocol FetchRecentFlickrPhotosUseCase {
    func execute(_ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void)
}
struct RetrieveRecentFlickrPhotosUseCase: FetchRecentFlickrPhotosUseCase {
    private let repo: FlickrPhotosRepository
    private let pageSize: Int
    
    init(repo: FlickrPhotosRepository, pageSize: Int) {
        self.repo = repo
        self.pageSize = pageSize
    }
    
    func execute(_ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void) {
        repo.fetchRecentPhotos(for: (1, pageSize), finished)
    }
}
