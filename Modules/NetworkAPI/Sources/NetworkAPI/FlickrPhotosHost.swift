//
//  FlickrPhotosHost.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

enum FlickrPhotosHost {
    case baseURL
    case photoURL(_ farm: Int)
    var path: String {
        switch self {
        case .baseURL:
            return "www.flickr.com"
        case let .photoURL(farm):
            return "farm\(farm).staticflickr.com"
        }
    }
}
