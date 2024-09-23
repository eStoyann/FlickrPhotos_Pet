//
//  HTTPMethod.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

public enum HTTPMethod {
    case get
    case post(parameters: [String: Any]? = nil)
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
    var parameters: [String: Any]? {
        if case let .post(parameters) = self {
            return parameters
        }
        return nil
    }
}

