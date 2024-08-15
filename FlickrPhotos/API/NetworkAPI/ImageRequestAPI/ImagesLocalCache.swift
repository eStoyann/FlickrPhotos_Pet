//
//  ImagesLocalCache.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation
import UIKit

protocol ImagesCache: AnyObject {
    var count: Int{get}
    subscript(_ url: URL) -> UIImage? {get set}
    func clean()
}
final class ImagesLocalCache: ImagesCache {
    
    private let cache: NSCache<NSString, UIImage>
    private let threadSafeCount = ThreadSafeVariable<Int>(.zero)
    
    var count: Int {
        threadSafeCount.value
    }
    
    init(countLimit: Int, totalCostLimit: Int) {
        cache = NSCache<NSString, UIImage>()
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }
    
    subscript(_ url: URL) -> UIImage? {
        get {
            cache.object(forKey: url.absoluteString.ns)
        }
        set {
            if let image = newValue {
                if cache.object(forKey: url.absoluteString.ns) == nil {
                    increaseCounter()
                    print("\n+++ New image for URL: \(url) is added to cache")
                }
                cache.setObject(image, forKey: url.absoluteString.ns)
            } else {
                if cache.object(forKey: url.absoluteString.ns) != nil {
                    decreaseCounter()
                }
                cache.removeObject(forKey: url.absoluteString.ns)
                print("\n--- Image for URL: \(url) is removed from cache")
            }
            print("\n+++ Count \(count)")
        }
    }
    
    func clean() {
        cache.removeAllObjects()
        threadSafeCount.value = 0
        print("\n--- All images are removed. Count: \(count)")
    }
}
private extension ImagesLocalCache {
    func increaseCounter() {
        if cache.countLimit > threadSafeCount.value {
            threadSafeCount.value += 1
        }
    }
    func decreaseCounter() {
        if threadSafeCount.value > 0 {
            threadSafeCount.value -= 1
        }
    }
}
