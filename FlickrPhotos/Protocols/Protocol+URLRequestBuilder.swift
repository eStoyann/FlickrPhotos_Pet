//
//  Protocol+URLRequestBuilder.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

protocol URLRequestBuilder {
    var httpMethod: HTTPMethod{get}
    var httpHeaders: [HTTPHeader]{get}
    var httpBodyParameters: [String: Any]?{get}
    
    func buildRequest() throws -> URLRequest
}
extension URLRequestBuilder {
    var httpBodyParameters: [String: Any]?{nil}
}
