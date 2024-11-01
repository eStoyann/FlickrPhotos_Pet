//
//  PhotosNetworkManager.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 18.07.2024.
//
import Foundation
import SimpleNetworkKit
import DomainModels

public protocol FlickrPhotosNetworkService: Sendable {
    typealias Page = (number: Int, size: Int)
    typealias CompletionHandler = @Sendable (HTTPResult<FlickrResponse, Error>) -> Void
    func getRecentPhotos(by page: Page,
                         _ finished: @escaping CompletionHandler)
    func searchPhoto(by searchTerm: String,
                     for page: Page,
                     _ finished: @escaping CompletionHandler)
}

public final class FlickrPhotosNetworkManager: FlickrPhotosNetworkService {
    public enum Errors: Error {
        case emptySearchTerm
    }
    private let client: HTTPClient
    private let decoder: JSONDecoder
    
    public init(client: HTTPClient = HTTPValidatedClient(),
                decoder: JSONDecoder = JSONDecoder()) {
        self.client = client
        self.decoder = decoder
    }
    
    public func searchPhoto(by searchTerm: String,
                            for page: Page,
                            _ finished: @escaping CompletionHandler) {
        guard searchTerm.isNotEmpty else {
            finished(.failure(Errors.emptySearchTerm))
            return
        }
        load(.photosBy(query: searchTerm,
                       page: page.number,
                       size: page.size)) { result in
            switch result {
            case let .success(response):
                finished(.success(response))
            case let .failure(error):
                finished(.failure(error))
            case .cancelled:
                finished(.cancelled)
            }
        }
    }
    public func getRecentPhotos(by page: Page,
                                _ finished: @escaping CompletionHandler) {
        load(.photos(page: page.number,
                     size: page.size),
             finished)
    }
}
private extension FlickrPhotosNetworkManager {
    func load(_ route: FlickrPhotosHTTPRouter,
              receiveOn queue: DispatchQueue = .main,
              _ finished: @escaping CompletionHandler) {
        do {
            let request = try route.endpoint.request()
            let task = client.fetch(request: request) {[weak self] result in
                guard let self else {return}
                switch result {
                case let .success((data, _)):
                    do {
                        let responseResult = try decoder.decode(Response<FlickrResponse>.self,
                                                                from: data)
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
}
