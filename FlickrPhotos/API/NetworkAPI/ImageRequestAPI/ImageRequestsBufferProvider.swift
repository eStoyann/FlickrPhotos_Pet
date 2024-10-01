//
//  ImageRequestsBufferProvider.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

protocol ImageRequestsBuffer {
    associatedtype Request: ImageURLRequest
    func add(_ request: Request)
    func remove(_ request: Request)
    func request(forURL url: URL) -> Request?
    func clean()
}
extension ImageRequestsBuffer {
    func removeRequest(forURL url: URL) {
        if let request = request(forURL: url) {
            remove(request)
        }
    }
}


final class ImageRequestsBufferProvider<Request>: ImageRequestsBuffer where Request: ImageURLRequest {
    
    private let threadSafeBuffer = ThreadSafeVariable(Set<Request>())
    private var buffer: Set<Request> {
        get {
            threadSafeBuffer.value
        }
        set {
            threadSafeBuffer.value = newValue
        }
    }
    
    func add(_ request: Request) {
        if buffer.insert(request).inserted {
            print("\n+++ New request \(request) is added to buffer. Buffer requests count: \(buffer.count)")
        }
    }
    func request(forURL url: URL) -> Request? {
        if let index = buffer.firstIndex(where: {$0.url == url}) {
            return buffer[index]
        }
        return nil
    }
    func remove(_ request: Request) {
        if let removedRequest = buffer.remove(request) {
            removedRequest.cancel()
            print("\n--- Request \(removedRequest) is removed from buffer. Buffer requests count: \(buffer.count)")
        }
    }
    func clean() {
        buffer.forEach(remove)
    }
}
