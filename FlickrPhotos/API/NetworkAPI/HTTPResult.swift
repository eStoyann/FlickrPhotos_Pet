//
//  HTTPResult.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 23.07.2024.
//

import Foundation

enum HTTPResult<T, E> where E: Error {
    case success(T)
    case failure(Error)
    case cancelled
}
