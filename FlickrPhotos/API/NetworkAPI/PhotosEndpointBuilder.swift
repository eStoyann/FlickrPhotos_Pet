//
//  PhotosEndpointBuilder.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

protocol EndpointBuilder {
    var endpoint: Endpoint {get}
}

enum PhotosEndpointBuilder: EndpointBuilder {
    case photos(page: Int, pageSize: Int, safeSearch: Int = 1)
    case photo(farm: Int, server: String, id: String, secret: String, size: String = "")
    case searchPhotos(text: String, page: Int, pageSize: Int, safeSearch: Int = 1)
    
    var endpoint: Endpoint {
        switch self {
        case .photos, .searchPhotos:
            return Endpoint(host: HTTPHost.baseURL.path,
                            urlPath: "/services/rest/",
                            queryParameters: queryParameters)
        case let .photo(farm, server, id, secret, size):
            let sizePath = size.isNotEmpty ? "_\(size)" : ""
            let urlPath = "/\(server)/\(id)_\(secret)\(sizePath).jpg"
            return Endpoint(host: HTTPHost.photoURL(farm).path,
                            urlPath: urlPath)
        }
    }
}
private extension PhotosEndpointBuilder {
    var queryParameters: [String: String]? {
        switch self {
        case let .photos(page, pageSize, safeSearch):
            var parameters = commonQueryParameters(page: page,
                                                   pageSize: pageSize,
                                                   safeSearch: safeSearch)
            parameters["method"] = "flickr.photos.getRecent"
            return parameters
        case let .searchPhotos(text, page, pageSize, safeSearch):
            var parameters = commonQueryParameters(page: page,
                                                   pageSize: pageSize,
                                                   safeSearch: safeSearch)
            parameters["method"] = "flickr.photos.search"
            parameters["text"] = "\(text)"
            return parameters
        case .photo:
            return nil
        }
    }
    func commonQueryParameters(page: Int, pageSize: Int, safeSearch: Int) -> [String: String] {
        [
            "api_key": "\(HTTPAPICredentials.key)",
            "format": "json",
            "nojsoncallback": "1",
            "safe_search": "\(safeSearch)",
            "per_page": "\(pageSize)",
            "page": "\(page)"
        ]
    }
}
