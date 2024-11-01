//
//  ImageRequestsBufferProvider.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

public protocol ImageRequestsBuffer: Sendable {
    associatedtype Request: ImageURLRequest
    var count: Int{get}
    func add(_ request: Request)
    func remove(_ request: Request)
    func request(forURL url: URL) -> Request?
    func clean()
}
extension ImageRequestsBuffer {
    public func removeRequest(forURL url: URL) {
        if let request = request(forURL: url) {
            remove(request)
        }
    }
}

public final class ImageRequestsBufferProvider<Request>: ImageRequestsBuffer where Request: ImageURLRequest {
    private let threadSafeBuffer = ThreadSafeVariable(Set<Request>())
    private var buffer: Set<Request> {
        get {
            threadSafeBuffer.value
        }
        set {
            threadSafeBuffer.value = newValue
        }
    }
    
    public var count: Int {
        buffer.count
    }
    
    public init(){}
    
    public func add(_ request: Request) {
        if buffer.insert(request).inserted {
            print("\n+++ New request \(request) is added to buffer. Buffer requests count: \(count)")
        }
    }
    public func request(forURL url: URL) -> Request? {
        if let index = buffer.firstIndex(where: {$0.url == url}) {
            return buffer[index]
        }
        return nil
    }
    public func remove(_ request: Request) {
        if let removedRequest = buffer.remove(request) {
            removedRequest.cancel()
            print("\n--- Request \(removedRequest) is removed from buffer. Buffer requests count: \(count)")
        }
    }
    public func clean() {
        buffer.forEach(remove)
    }
}
