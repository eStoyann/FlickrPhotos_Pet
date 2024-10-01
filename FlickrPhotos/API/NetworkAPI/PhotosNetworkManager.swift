//
//  PhotosNetworkManager.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 18.07.2024.
//

import Foundation

protocol PhotosNetworkService {
    typealias CompletionHandler = (HTTPResult<PhotosResponse>) -> Void
    func getRecentPhotos(byPage page: Page,
                         _ finished: @escaping CompletionHandler)
    func searchPhoto(bySearchTerm searchTerm: String,
                     page: Page,
                     _ finished: @escaping CompletionHandler)
    func loadNextPhotosPage(bySearchTerm searchTerm: String?,
                            page: Page,
                            _ finished: @escaping CompletionHandler)
}
final class PhotosNetworkManager: PhotosNetworkService {
    enum Errors: LocalizedError {
        case emptySearchTerm
        case invalidHTTPResponse(statusCode: Int)
    }
    private let client: HTTPClient
    private let decoder: JSONDecoder
    
    init(client: HTTPClient = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.client = client
        self.decoder = decoder
    }
    
    func searchPhoto(bySearchTerm searchTerm: String,
                     page: Page,
                     _ finished: @escaping CompletionHandler) {
        guard searchTerm.isNotEmpty else {
            finished(.failure(Errors.emptySearchTerm))
            return
        }
        load(.photosBy(query: searchTerm,
                       page: page)) { result in
            switch result {
            case var .success(response):
                response.searchTerm = searchTerm
                finished(.success(response))
            case let .failure(error):
                finished(.failure(error))
            case .cancelled:
                finished(.cancelled)
            }
        }
    }
    func getRecentPhotos(byPage page: Page,
                         _ finished: @escaping CompletionHandler) {
        load(.photos(page: page), finished)
    }
    func loadNextPhotosPage(bySearchTerm searchTerm: String?,
                            page: Page,
                            _ finished: @escaping CompletionHandler) {
        if let term = searchTerm {
            searchPhoto(bySearchTerm: term, page: page) { result in
                guard searchTerm == term else {
                    finished(.cancelled)
                    return
                }
                finished(result)
            }
        } else {
            getRecentPhotos(byPage: page) { result in
                guard searchTerm == nil else {
                    finished(.cancelled)
                    return
                }
                finished(result)
            }
        }
    }
}
private extension PhotosNetworkManager {
    func load(_ route: PhotosHTTPRouter,
              receiveOn queue: DispatchQueue = .main,
              _ finished: @escaping CompletionHandler) {
        do {
            let request = try route.endpoint.request()
            let task = client.load(request) {[weak self] result in
                guard let self else {return}
                switch result {
                case let .success((data, httpResponse)):
                    do {
                        try validate(httpURLResponse: httpResponse)
                        let responseResult = try decoder.decode(Response<PhotosResponse>.self, from: data)
                        switch responseResult {
                        case let .success(response):
                            queue.async {
                                finished(.success(response))
                            }
                        case let .failure(error):
                            queue.async {
                                finished(.failure(error))
                            }
                        }
                    } catch {
                        queue.async {
                            finished(.failure(error))
                        }
                    }
                case let .failure(error):
                    queue.async {
                        finished(error.isURLRequestCancelled ? .cancelled : .failure(error))
                    }
                }
            }
            task.start()
        } catch {
            queue.async {
                finished(.failure(error))
            }
        }
    }
    func validate(httpURLResponse: HTTPURLResponse) throws {
        guard httpURLResponse.statusCode == 200 else {
            throw Errors.invalidHTTPResponse(statusCode: httpURLResponse.statusCode)
        }
    }
}
