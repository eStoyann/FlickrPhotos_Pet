//
//  ImagesLoadingManager.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

protocol ImageLoader: AnyObject {
    associatedtype Request: ImageURLRequest
    var bufferRequestsCount: Int{get}
    var cachedImagesCount: Int{get}
    func runAndCacheResult(of request: Request,
                           receiveOn queue: DispatchQueue,
                           _ finished: @escaping ImageURLRequest.CompletionHandler)
    func stopRequest(forURL url: URL)
    func isActiveRequest(forURL url: URL) -> Bool
    func stopAllRequests()
    func cleanCachedData()
}


final class ImagesLoadingManager<Buffer, Cache, Request>: ImageLoader where Buffer: ImageRequestsBuffer,
                                                                                      Request == Buffer.Request,
                                                                                      Cache: ImagesCache {
    private let buffer: Buffer
    private let cache: Cache
    
    var bufferRequestsCount: Int {
        buffer.count
    }
    var cachedImagesCount: Int {
        cache.count
    }
    
    init(buffer: Buffer, cache: Cache) {
        self.buffer = buffer
        self.cache = cache
    }
    
    func runAndCacheResult(of request: Request,
                           receiveOn queue: DispatchQueue = .main,
                           _ finished: @escaping ImageURLRequest.CompletionHandler) {
        if cache[request.url] == nil {
            if buffer.request(forURL: request.url) == nil {
                request.start {[weak self] image in
                    guard let self else {return}
                    cache[request.url] = image
                    queue.async {
                        finished(image)
                        self.buffer.remove(request: request)
                    }
                }
                buffer.add(request: request)
            }
        } else {
            queue.async {[weak self] in
                guard let self else {return}
                finished(cache[request.url])
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
        buffer.request(forURL: url) != nil
    }
    func cleanCachedData() {
        cache.clean()
    }
}

