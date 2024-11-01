//
//  ImageRequest.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//
import Foundation
import UIKit
import SimpleNetworkKit

public protocol ImageURLRequest: Hashable, Sendable {
    typealias CompletionHandler = @Sendable (UIImage?) -> Void
    var url: URL{get}
    var isCancelled: Bool{get}
    
    func start(_ finished: @escaping CompletionHandler)
    func cancel()
    
    init(url: URL, timeout: TimeInterval, client: HTTPClient)
}
extension ImageURLRequest {
    public init(url: URL) {
        self.init(url: url, timeout: 15, client: URLSession.shared)
    }
}

public final class ImageRequest: ImageURLRequest, @unchecked Sendable {
    private var task: HTTPClientTask?
    private let urlRequest: URLRequest
    private let client: HTTPClient
    
    public var url: URL {
        urlRequest.url!
    }
    public var isCancelled: Bool {
        task == nil || task!.status == .canceling
    }
    
    public init(url: URL,
                timeout: TimeInterval,
                client: HTTPClient) {
        self.urlRequest = URLRequest(url: url, timeoutInterval: timeout)
        self.client = client
    }
    
    public func start(_ finished: @escaping CompletionHandler) {
        guard isCancelled else {
            finished(nil)
            return
        }
        print("\n+++ Start loading image from \(urlRequest)...")
        let copy = urlRequest
        task = client.fetch(request: urlRequest) {[weak self] result in
            guard let self else {return}
            guard copy == urlRequest else {
                print("\n--- Different urls")
                finished(nil)
                return
            }
            switch result {
            case let .success((data, _)):
                if let image = UIImage(data: data) {
                    print("\n+++ Image from URL: \(copy) has loaded")
                    finished(image)
                } else {
                    print("\n--- Invalid image data")
                    finished(nil)
                }
            case let .failure(error):
                if error.isURLRequestCancelled {
                    print("\n--- Image loading operation \(copy) is cancelled")
                } else {
                    print("\n--- Error: \(error.localizedDescription)")
                }
                finished(nil)
            }
        }
        task!.start()
    }
    public func cancel() {
        task?.stop()
        task = nil
    }
    deinit {
        cancel()
    }
}
extension ImageRequest {
    public static func == (lhs: ImageRequest, rhs: ImageRequest) -> Bool {
        lhs.urlRequest == rhs.urlRequest
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(urlRequest)
    }
}
extension ImageRequest: CustomStringConvertible {
    public var description: String {
        "url: \(url)"
    }
}

