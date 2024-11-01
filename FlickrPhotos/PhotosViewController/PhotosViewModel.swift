//
//  PhotosViewModel.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 19.07.2024.
//
import UIKit
import NetworkAPI
import DomainModels

final class PhotosViewModel: PhotosViewModelProtocol {
    struct UseCases {
        let fetchRecentPhotos: FetchRecentFlickrPhotosUseCase
        let searchPhotos: SearchFlickrPhotosUseCase
        let fetchNextPhotosPage: FetchNextFlickrPhotosPageUseCase
        let stopAllRequestsAndCleanCache: StopAllRequestsAndCleanCacheUseCase
        let startLoadingPhoto: StartLoadingFlickrPhotoUseCase
        let stopLoadingPhoto: StopLoadingFlickrPhotoUseCase
        let getStatusOfLoadingPhoto: GetStatusOfLoadingFlickrPhotoUseCase
        let storeSearchTerm: StoreSearchTermUseCase
    }
    
    //MARK: - Private properties
    private var flickrResponse: FlickrResponse?
    private let useCases: UseCases
    
    //MARK: - Public properties
    let selectedSearchTerm = Publisher<String?>(nil)
    let loadNextPhotosPageOperationStatus = OperationStatus<[IndexPath], Error>.publisher
    let loadRecentPhotosOperationStatus = OperationStatus<Bool, Error>.publisher
    var title: String {
        "Flickr Photos"
    }
    var searchBarPlaceholder: String {
        "Search photos"
    }
    var photosSearchTermsHistoryViewModel: PhotosSearchTermsHistoryViewModel {
        let storage = SearchTermsHistoryLocalStorage()
        let repo = SearchTermsRepo(storage: storage)
        let fetchSearchTerms = RetrieveSearchTermsUseCase(repo: repo)
        let useCases = PhotosSearchTermsHistoryViewModel.UseCases(fetchSearchTerms: fetchSearchTerms)
        let viewModel = PhotosSearchTermsHistoryViewModel(useCases: useCases)
        viewModel.onSelect = {[weak self] searchTerm in
            guard let self else {return}
            if selectedSearchTerm.value != searchTerm {
                search(for: searchTerm)
            } else {
                selectedSearchTerm.value = nil
                selectedSearchTerm.value = searchTerm
            }
        }
        return viewModel
    }
    
    //MARK: - Lifecycle
    init(useCases: UseCases) {
        self.useCases = useCases
    }
    
    //MARK: - Public methods
    func getPhotos() {
        useCases.stopAllRequestsAndCleanCache.execute()
        loadRecentPhotosOperationStatus.value = .performing
        useCases.fetchRecentPhotos.execute {[weak self] result in
            guard let self else {return}
            switch result {
            case let .success(response):
                self.flickrResponse = response
                self.loadRecentPhotosOperationStatus.value = .performed(true)
            case let .failure(error):
                self.loadRecentPhotosOperationStatus.value = .failed(error)
            case .cancelled:
                break
            }
            self.loadRecentPhotosOperationStatus.value = .idle
        }
    }
}
//MARK: - PhotosDataSource
extension PhotosViewModel: PhotosDataSource {
    func numberOfPhotos(in section: Int) -> Int {
        flickrResponse?.page.photos.count ?? 0
    }
    func startLoadingImage(at indexPath: IndexPath,
                           _ finished: @escaping (UIImage?) -> Void) {
        guard let url = url(at: indexPath) else {return}
        useCases.startLoadingPhoto.execute(for: url) { image in
                image?.prepareForDisplay { preparedImage in
                    DispatchQueue.main.async {
                        finished(preparedImage)
                    }
                } ?? finished(nil)
            }
    }
    func isLoadingImage(at indexPath: IndexPath) -> Bool {
        if let url = url(at: indexPath) {
            return useCases.getStatusOfLoadingPhoto.execute(for: url)
        }
        return false
    }
    func stopLoadingImage(at indexPath: IndexPath) {
        if let url = url(at: indexPath) {
            useCases.stopLoadingPhoto.execute(for: url)
        }
    }
    func loadNextPhotosPage() {
        if !loadNextPhotosPageOperationStatus.value.inProgress,
           let nextPage = flickrResponse?.page.next {
            loadNextPhotosPageOperationStatus.value = .performing
            useCases
                .fetchNextPhotosPage
                .execute(by: selectedSearchTerm.value,
                         for: nextPage) {[weak self] result in
                    guard let self else {return}
                    switch result {
                    case let .success(response):
                        let indices = self.indices(of: response.page)
                        self.updatePhotosResponse(byNewOne: response)
                        self.loadNextPhotosPageOperationStatus.value = .performed(indices)
                    case let .failure(error):
                        self.loadNextPhotosPageOperationStatus.value = .failed(error)
                    case .cancelled:
                        break
                    }
                    self.loadNextPhotosPageOperationStatus.value = .idle
                }
        }
    }
}
//MARK: - PhotosSearchTermsDelegate
extension PhotosViewModel: PhotosSearchTermsDelegate {
    func search(for searchTerm: String) {
        guard searchTerm.isNotEmpty else {return}
        selectedSearchTerm.value = searchTerm
        useCases.storeSearchTerm.execute(searchTerm)
        if !loadRecentPhotosOperationStatus.value.inProgress {
            useCases.stopAllRequestsAndCleanCache.execute()
            loadRecentPhotosOperationStatus.value = .performing
            useCases.searchPhotos.execute(by: searchTerm) {[weak self] result in
                    guard let self else {return}
                    switch result {
                    case let .success(response):
                        self.flickrResponse = response
                        self.loadRecentPhotosOperationStatus.value = .performed(true)
                    case let .failure(error):
                        self.loadRecentPhotosOperationStatus.value = .failed(error)
                    case .cancelled:
                        break
                    }
                    self.loadRecentPhotosOperationStatus.value = .idle
                }
        }
    }
    func cleanSelectedSearchTerm() {
        if selectedSearchTerm.value != nil {
            selectedSearchTerm.value = nil
            getPhotos()
        }
    }
}
private extension PhotosViewModel {
    func url(at indexPath: IndexPath) -> URL? {
        if numberOfPhotos(in: indexPath.section) > indexPath.row {
            let photo = flickrResponse!.page.photos[indexPath.row]
            let endpoint = FlickrPhotosHTTPRouter.photo(farm: photo.farm,
                                                        server: photo.server,
                                                        id: photo.id,
                                                        secret: photo.secret,
                                                        resolution: .q).endpoint
            if let url = try? endpoint.request().url {
                return url
            }
        }
        return nil
    }
    func indices(of page: FlickrResponse.Page) -> Array<IndexPath> {
        guard !page.photos.isEmpty else {
            return []
        }
        guard let oldPage = flickrResponse?.page else {
            return page.photos.indices.map{IndexPath(row: $0, section: 0)}
        }
        let oldPhotosCount = oldPage.photos.count
        let newPhotosCount = page.photos.count
        let allPhotosCount = oldPhotosCount+newPhotosCount
        return (oldPhotosCount..<allPhotosCount).map{IndexPath(row: $0, section: 0)}
    }
    func updatePhotosResponse(byNewOne response: FlickrResponse) {
        guard let oldResponse = flickrResponse else {
            flickrResponse = response
            return
        }
        var photos = FlickrResponse.Page.Photos()
        photos.append(contentsOf: oldResponse.page.photos)
        photos.append(contentsOf: response.page.photos)
        flickrResponse = response.new(by: photos)
    }
}
