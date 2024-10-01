//
//  ImagesLocalCache.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation
import UIKit

protocol ImagesCache {
    func image(forURL url: URL) -> UIImage?
    func set(_ image: UIImage?, forURL url: URL)
    func clean()
}
final class ImagesLocalCache: ImagesCache {
    private let cache: NSCache<NSString, UIImage>
    
    init(countLimit: Int = 0,
         totalCostLimit: Int = 0) {
        self.cache = NSCache<NSString, UIImage>()
        self.cache.countLimit = countLimit
        self.cache.totalCostLimit = totalCostLimit
    }
    func image(forURL url: URL) -> UIImage? {
        cache.object(forKey: url.string)
    }
    func set(_ image: UIImage?, forURL url: URL) {
        if let image {
            cache.setObject(image, forKey: url.string)
            print("\n+++ New image for URL: \(url) is added to cache")
        } else {
            cache.removeObject(forKey: url.string)
            print("\n--- Image for URL: \(url) is removed from cache")
        }
    }
    func clean() {
        cache.removeAllObjects()
    }
}
