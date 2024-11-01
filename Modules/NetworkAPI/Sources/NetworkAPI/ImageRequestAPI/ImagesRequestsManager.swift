//
//  ImagesRequestsManager.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation
import UIKit

public protocol ImageLoader {
    associatedtype Request: ImageURLRequest
    func load(_ request: Request,
              receiveOn queue: DispatchQueue,
              _ finished: @escaping ImageURLRequest.CompletionHandler)
    func stopRequest(forURL url: URL)
    func isActiveRequest(forURL url: URL) -> Bool
    func stopAllRequests()
    func cleanCachedData()
}

public final class ImagesRequestsManager<Buffer, Cache, Request>: ImageLoader where Buffer: ImageRequestsBuffer,
                                                                                    Request == Buffer.Request,
                                                                                    Cache: ImagesCache {
    private let buffer: Buffer
    private let cache: Cache
    
    public var bufferRequestsCount: Int{
        buffer.count
    }
    public var cachedImagesCount: Int{
        cache.count
    }
    
    public init(buffer: Buffer, cache: Cache) {
        self.buffer = buffer
        self.cache = cache
    }
    
    public func load(_ request: Request,
                     receiveOn queue: DispatchQueue = .main,
                     _ finished: @escaping ImageURLRequest.CompletionHandler) {
        if cache.image(forURL: request.url) == nil {
            if buffer.request(forURL: request.url) == nil {
                request.start {[weak self] image in
                    guard let self else {return}
                    cache.set(image, forURL: request.url)
                    queue.async {
                        finished(image)
                        self.buffer.remove(request)
                    }
                }
                buffer.add(request)
            }
        } else {
            queue.async {[cache] in
                finished(cache.image(forURL: request.url))
            }
        }
    }
    public func stopRequest(forURL url: URL) {
        buffer.removeRequest(forURL: url)
    }
    public func stopAllRequests() {
        buffer.clean()
    }
    public func isActiveRequest(forURL url: URL) -> Bool {
        if cache.image(forURL: url) != nil {
            return false
        }
        return buffer.request(forURL: url) != nil
    }
    public func cleanCachedData() {
        cache.clean()
    }
}

