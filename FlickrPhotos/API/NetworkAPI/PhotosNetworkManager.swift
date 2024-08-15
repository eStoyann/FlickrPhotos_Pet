//
//  PhotosNetworkManager.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 18.07.2024.
//

import Foundation

protocol PhotosNetworkService {
    typealias CompletionHandler = (HTTPResult<PhotosResponse, Error>) -> Void
    func getRecentPhotos(forPage page: Int,
                         pageSize: Int,
                         _ finished: @escaping CompletionHandler)
    func searchPhoto(for searchTerm: String,
                     page: Int,
                     pageSize: Int,
                     _ finished: @escaping CompletionHandler)
    func loadNextPhotosPage(for searchTerm: String?,
                            page: Int,
                            pageSize: Int,
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
    
    func searchPhoto(for searchTerm: String,
                     page: Int,
                     pageSize: Int,
                     _ finished: @escaping CompletionHandler) {
        guard searchTerm.isNotEmpty else {
            finished(.failure(Errors.emptySearchTerm))
            return
        }
        let endpoint = PhotosEndpointBuilder.searchPhotos(text: searchTerm,
                                                          page: page,
                                                          pageSize: pageSize).endpoint
        let builder = PhotosURLRequestBuilder(endpoint: endpoint)
        fetchRequest(fromBuilder: builder) { result in
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
    func getRecentPhotos(forPage page: Int,
                         pageSize: Int,
                         _ finished: @escaping CompletionHandler) {
        let endpoint = PhotosEndpointBuilder.photos(page: page,
                                                    pageSize: pageSize).endpoint
        let builder = PhotosURLRequestBuilder(endpoint: endpoint)
        fetchRequest(fromBuilder: builder, finished)
    }
    func loadNextPhotosPage(for searchTerm: String?,
                            page: Int,
                            pageSize: Int,
                            _ finished: @escaping CompletionHandler) {
        if let term = searchTerm {
            searchPhoto(for: term, page: page, pageSize: pageSize, { result in
                guard searchTerm == term else {
                    finished(.cancelled)
                    return
                }
                finished(result)
            })
        } else {
            getRecentPhotos(forPage: page, pageSize: pageSize, { result in
                guard searchTerm == nil else {
                    finished(.cancelled)
                    return
                }
                finished(result)
            })
        }
    }
}
private extension PhotosNetworkManager {
    func fetchRequest(fromBuilder builder: PhotosURLRequestBuilder,
                      receiveOn queue: DispatchQueue = .main,
                      _ finished: @escaping CompletionHandler) {
        do {
            let request = try builder.buildRequest()
            let task = client.fetch(request: request) {[weak self] result in
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
                        finished(.failure(error))
                    }
                case .cancelled:
                    queue.async {
                        finished(.cancelled)
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
