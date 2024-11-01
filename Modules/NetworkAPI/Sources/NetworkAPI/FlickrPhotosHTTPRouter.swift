//
//  PhotosHTTPRouter.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//
import Foundation
import DomainModels
import SimpleNetworkKit

public protocol NetworkRoutable {
    var endpoint: HTTPEndpoint {get}
}

public enum FlickrPhotosHTTPRouter: NetworkRoutable {
    case photos(page: Int,
                size: Int,
                safeLevel: Int = 1)
    case photosBy(query: String,
                  page: Int,
                  size: Int,
                  safeLevel: Int = 1)
    case photo(farm: Int,
               server: String,
               id: String,
               secret: String,
               resolution: FlickrPhotoResolution = .default)
    
    public var endpoint: HTTPEndpoint {
        switch self {
        case .photos, .photosBy:
            let path = "/services/rest"
            let host = FlickrPhotosHost.baseURL.path
            let builder = URLBuilder(host: host,
                                     path: path,
                                     queryParameters: queryParameters)
            let endpoint = Endpoint(urlBuilder: builder)
            return endpoint
        case let .photo(farm, server, id, secret, resolution):
            let path = "/\(server)/\(id)_\(secret)\(resolution.lastPath).jpg"
            let host = FlickrPhotosHost.photoURL(farm).path
            let builder = URLBuilder(host: host, path: path)
            let endpoint = Endpoint(urlBuilder: builder)
            return endpoint
        }
    }
}
private extension FlickrPhotosHTTPRouter {
    var queryParameters: [String: String]? {
        switch self {
        case let .photos(page, size, safeLevel):
            var parameters = defaultQueryParameters(page: page,
                                                    size: size,
                                                    safeLevel: safeLevel)
            parameters["method"] = "flickr.photos.getRecent"
            return parameters
        case let .photosBy(query, page, size, safeLevel):
            var parameters = defaultQueryParameters(page: page,
                                                    size: size,
                                                    safeLevel: safeLevel)
            parameters["method"] = "flickr.photos.search"
            parameters["text"] = "\(query)"
            return parameters
        case .photo:
            return nil
        }
    }
    func defaultQueryParameters(page: Int, size: Int, safeLevel: Int) -> [String: String] {
        [
            "api_key": "\(FlickrPhotosAPICredentials.key)",
            "format": "json",
            "nojsoncallback": "1",
            "safe_search": "\(safeLevel)",
            "per_page": "\(size)",
            "page": "\(page)"
        ]
    }
}

