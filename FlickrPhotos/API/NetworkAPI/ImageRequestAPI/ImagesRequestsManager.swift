//
//  ImagesRequestsManager.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

protocol ImageLoader: AnyObject {
    associatedtype Request: ImageURLRequest
    
    func load(_ request: Request,
              receiveOn queue: DispatchQueue,
              _ finished: @escaping ImageURLRequest.CompletionHandler)
    func stopRequest(forURL url: URL)
    func isActiveRequest(forURL url: URL) -> Bool
    func stopAllRequests()
    func cleanCachedData()
}


final class ImagesRequestsManager<Buffer, Cache, Request>: ImageLoader where Buffer: ImageRequestsBuffer,
                                                                             Request == Buffer.Request,
                                                                             Cache: ImagesCache {
    private let buffer: Buffer
    private let cache: Cache
    
    var bufferRequestsCount: Int{
        buffer.count
    }
    var cachedImagesCount: Int{
        cache.count
    }
    
    init(buffer: Buffer, cache: Cache) {
        self.buffer = buffer
        self.cache = cache
    }
    
    func load(_ request: Request,
              receiveOn queue: DispatchQueue = .main,
              _ finished: @escaping ImageURLRequest.CompletionHandler) {
        if cache.image(forURL: request.url) == nil {
            if buffer.request(forURL: request.url) == nil {
                request.start {[cache, buffer] image in
                    cache.set(image, forURL: request.url)
                    queue.async {
                        finished(image)
                        buffer.remove(request)
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
    func stopRequest(forURL url: URL) {
        buffer.removeRequest(forURL: url)
    }
    func stopAllRequests() {
        buffer.clean()
    }
    func isActiveRequest(forURL url: URL) -> Bool {
        if cache.image(forURL: url) != nil {
            return false
        }
        return buffer.request(forURL: url) != nil
    }
    func cleanCachedData() {
        cache.clean()
    }
}

