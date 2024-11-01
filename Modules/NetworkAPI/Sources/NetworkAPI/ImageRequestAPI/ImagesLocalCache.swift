//
//  ImagesLocalCache.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//
import Foundation
import UIKit

public protocol ImagesCache: Sendable {
    var count: Int{get}
    func image(forURL url: URL) -> UIImage?
    func set(_ image: UIImage?, forURL url: URL)
    func clean()
}

public final class ImagesLocalCache: ImagesCache, @unchecked Sendable {
    private let counter: Counter
    private let cache: NSCache<NSString, UIImage>
    
    public var count: Int {
        counter.count.value
    }
    
    public init(countLimit: Int = 0,
         totalCostLimit: Int = 0) {
        self.cache = NSCache<NSString, UIImage>()
        self.cache.countLimit = countLimit
        self.cache.totalCostLimit = totalCostLimit
        self.counter = Counter(limit: countLimit, count: ThreadSafeVariable<Int>(0))
    }
    public func image(forURL url: URL) -> UIImage? {
        cache.object(forKey: url.path)
    }
    public func set(_ image: UIImage?, forURL url: URL) {
        if let image {
            if self.image(forURL: url) == nil {
                counter.increment()
            }
            cache.setObject(image, forKey: url.path)
            print("\n+++ New image for URL: \(url) is added to cache")
        } else {
            if self.image(forURL: url) != nil {
                counter.decrement()
            }
            cache.removeObject(forKey: url.path)
            print("\n--- Image for URL: \(url) is removed from cache")
        }
    }
    public func clean() {
        cache.removeAllObjects()
        counter.reset()
    }
}


fileprivate final class Counter {
    let limit: Int
    var count: ThreadSafeVariable<Int>
    
    init(limit: Int, count: ThreadSafeVariable<Int>) {
        self.limit = limit
        self.count = count
    }
    
    func increment() {
        if count.value < limit {
            count.value += 1
        }
    }
    func decrement() {
        if count.value > 0 {
            count.value -= 1
        }
    }
    func reset() {
        count.value = 0
    }
}
