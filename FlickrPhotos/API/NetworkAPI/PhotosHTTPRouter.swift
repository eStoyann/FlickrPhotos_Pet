//
//  PhotosHTTPRouter.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

enum PhotosHTTPRouter {
    case photos(page: Page,
                safeLevel: Int = 1)
    case photosBy(query: String,
                  page: Page,
                  safeLevel: Int = 1)
    case photo(farm: Int,
               server: String,
               id: String,
               secret: String,
               resolution: PhotoResolution = .default)
    
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
        case let .photo(farm, server, id, secret, resolution):
            let path = "/\(server)/\(id)_\(secret)\(resolution.path).jpg"
            let host = HTTPHost.photoURL(farm).path
            let builder = URLBuilder(host: host, path: path)
            let endpoint = Endpoint(builder: builder)
            return endpoint
        }
    }
}
private extension PhotosHTTPRouter {
    var queryParameters: [String: String]? {
        switch self {
        case let .photos(page, safeLevel):
            var parameters = defaultQueryParameters(page: page,
                                                    safeLevel: safeLevel)
            parameters["method"] = "flickr.photos.getRecent"
            return parameters
        case let .photosBy(query, page, safeLevel):
            var parameters = defaultQueryParameters(page: page,
                                                    safeLevel: safeLevel)
            parameters["method"] = "flickr.photos.search"
            parameters["text"] = "\(query)"
            return parameters
        case .photo:
            return nil
        }
    }
    func defaultQueryParameters(page: Page, safeLevel: Int) -> [String: String] {
        [
            "api_key": "\(HTTPAPICredentials.key)",
            "format": "json",
            "nojsoncallback": "1",
            "safe_search": "\(safeLevel)",
            "per_page": "\(page.size)",
            "page": "\(page.number)"
        ]
    }
}


struct Page {
    let number: Int
    let size: Int
    
    init(number: Int = 1, size: Int = 24) {
        self.number = number
        self.size = size
    }
}
