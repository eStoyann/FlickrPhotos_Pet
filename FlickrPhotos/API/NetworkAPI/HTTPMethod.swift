//
//  HTTPMethod.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

enum HTTPMethod {
    case get
    case post(_ httpBody: HTTPBody)
    case delete
    case put
    case patch
    
    var value: String {
        switch self {
        case .delete:
            return "DELETE"
        case .get:
            return "GET"
        case .patch:
            return "PATCH"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        }
    }
    var body: HTTPBody? {
        if case let .post(httpBody) = self {
            return httpBody
        }
        return nil
    }
}

