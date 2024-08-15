//
//  PhotosURLRequestBuilder.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

final class PhotosURLRequestBuilder: URLRequestBuilder {
    let httpMethod: HTTPMethod
    let httpHeaders: [HTTPHeader]
    let endpoint: Endpoint
    let timeoutInterval: TimeInterval
    let cachePolicy: URLRequest.CachePolicy
    
    init(endpoint: Endpoint,
         method: HTTPMethod = .get,
         headers: [HTTPHeader] = [.contentType],
         timeoutInterval: TimeInterval = 60,
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) {
        self.httpMethod = method
        self.httpHeaders = headers
        self.endpoint = endpoint
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
    }
    
    func buildRequest() throws -> URLRequest {
        guard let url = endpoint.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url,
                                 cachePolicy: cachePolicy,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = httpMethod.rawValue
        httpHeaders.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.rawValue)
        }
        return request
    }
}
