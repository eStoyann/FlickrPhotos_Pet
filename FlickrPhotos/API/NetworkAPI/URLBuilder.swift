//
//  URLBuilder.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation
protocol HTTPURLBuilder {
    var url: URL? {get}
}

struct URLBuilder: HTTPURLBuilder {
    typealias QueryParameters = [String: String]
    private var components: URLComponents
    
    var url: URL? {
        components.url
    }
    
    init(scheme: HTTPScheme = .https,
         host: String,
         path: String,
         queryParameters: QueryParameters? = nil) {
        self.components = URLComponents()
        self.components.scheme = scheme.rawValue
        self.components.host = host
        self.components.path = path
        self.components.percentEncodedQueryItems = queryParameters?.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
    }
}
