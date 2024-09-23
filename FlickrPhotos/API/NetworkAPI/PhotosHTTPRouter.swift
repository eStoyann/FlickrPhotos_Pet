//
//  PhotosHTTPRouter.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

enum PhotosHTTPRouter {
    case photos(page: Int, pageSize: Int, safeLevel: Int = 1)
    case photo(farm: Int, server: String, id: String, secret: String, size: String = "")
    case photosBy(query: String, page: Int, pageSize: Int, safeLevel: Int = 1)
    
    var endpoint: HTTPEndpoint {
        switch self {
        case .photos, .photosBy:
            let path = "/services/rest/"
            let host = HTTPHost.baseURL.path
            let builder = URLBuilder(host: host,
                            path: path,
                            queryParameters: queryParameters)
            let endpoint = Endpoint(builder: builder)
            return endpoint
        case let .photo(farm, server, id, secret, size):
            let host = HTTPHost.photoURL(farm).path
            let sizePath = size.isNotEmpty ? "_\(size)" : ""
            let path = "/\(server)/\(id)_\(secret)\(sizePath).jpg"
            let builder = URLBuilder(host: host, path: path)
            let endpoint = Endpoint(builder: builder)
            return endpoint
        }
    }
}
private extension PhotosHTTPRouter {
    var queryParameters: [String: String]? {
        switch self {
        case let .photos(page, pageSize, safeLevel):
            var parameters = commonQueryParameters(page: page,
                                                   pageSize: pageSize,
                                                   safeLevel: safeLevel)
            parameters["method"] = "flickr.photos.getRecent"
            return parameters
        case let .photosBy(text, page, pageSize, safeLevel):
            var parameters = commonQueryParameters(page: page,
                                                   pageSize: pageSize,
                                                   safeLevel: safeLevel)
            parameters["method"] = "flickr.photos.search"
            parameters["text"] = "\(text)"
            return parameters
        case .photo:
            return nil
        }
    }
    func commonQueryParameters(page: Int, pageSize: Int, safeLevel: Int) -> [String: String] {
        [
            "api_key": "\(HTTPAPICredentials.key)",
            "format": "json",
            "nojsoncallback": "1",
            "safe_search": "\(safeLevel)",
            "per_page": "\(pageSize)",
            "page": "\(page)"
        ]
    }
}
