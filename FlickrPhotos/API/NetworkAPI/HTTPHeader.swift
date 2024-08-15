//
//  HTTPHeader.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

enum HTTPHeader: String {
    case contentType = "Content-Type"
    var value: String {
        switch self {
        case .contentType:
            return "application/json"
        }
    }
}
