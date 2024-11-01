//
//  FetchNextFlickrPhotosPageUseCase.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import DomainModels
import SimpleNetworkKit

protocol FetchNextFlickrPhotosPageUseCase {
    func execute(by searchText: String?,
                 for page: Int,
                 _ finished: @escaping @Sendable (HTTPResult<FlickrResponse, Error>) -> Void)
}
struct RetrieveNextFlickrPhotosPageUseCase: FetchNextFlickrPhotosPageUseCase {
    private let repo: FlickrPhotosRepository
    private let pageSize: Int

    init(repo: FlickrPhotosRepository, pageSize: Int) {
        self.repo = repo
        self.pageSize = pageSize
    }

    func execute(by searchText: String?,
                 for page: Int,
                 _ finished: @escaping @Sendable(HTTPResult<FlickrResponse, Error>) -> Void) {
        if let searchText {
            repo.searchPhotos(by: searchText, for: (page, pageSize), finished)
        } else {
            repo.fetchRecentPhotos(for: (page, pageSize), finished)
        }
    }
}
