//
//  Endpoint.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

protocol HTTPEndpoint {
    func request() throws -> URLRequest
}

final class Endpoint: HTTPEndpoint {
    let httpMethod: HTTPMethod
    let httpHeaders: [HTTPHeader]
    let builder: URLBuilder
    let timeoutInterval: TimeInterval
    let cachePolicy: URLRequest.CachePolicy
    
    init(builder: URLBuilder,
         method: HTTPMethod = .get,
         headers: [HTTPHeader] = [.contentType],
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
         timeoutInterval: TimeInterval = 60) {
        self.httpMethod = method
        self.httpHeaders = headers
        self.builder = builder
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
    }
    
    func request() throws -> URLRequest {
        guard let url = builder.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url,
                                 cachePolicy: cachePolicy,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = httpMethod.value
        httpHeaders.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.rawValue)
        }
        if let parameters = httpMethod.parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        return request
    }
}
