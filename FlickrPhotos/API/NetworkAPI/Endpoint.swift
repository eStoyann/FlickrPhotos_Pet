//
//  Endpoint.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

struct Endpoint {
    typealias QueryParameters = [String: String]
    private var components: URLComponents
    
    var url: URL? {
        components.url
    }
    
    init(scheme: HTTPScheme = .https,
         host: String,
         urlPath: String,
         queryParameters: QueryParameters? = nil) {
        self.components = URLComponents()
        self.components.scheme = scheme.rawValue
        self.components.host = host
        self.components.path = urlPath
        self.components.percentEncodedQueryItems = queryParameters?.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
    }
}
extension Endpoint {
    var scheme: HTTPScheme? {
        HTTPScheme(rawValue: components.scheme ?? "")
    }
    var host: String? {
        components.host
    }
    var path: String {
        components.path
    }
    var queryParameters: [String: String] {
        var queryParameters = [String: String]()
        components.queryItems?.forEach{ item in
            queryParameters[item.name] = item.value
        }
        return queryParameters
    }
}
