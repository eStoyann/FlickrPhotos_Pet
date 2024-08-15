//
//  ImageRequest.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation
import UIKit

protocol ImageURLRequest: AnyObject, Hashable {
    typealias CompletionHandler = (UIImage?) -> Void
    var url: URL{get}
    var isCancelled: Bool{get}
    
    init(url: URL, timeout: TimeInterval, client: HTTPClient)
    
    func start(_ finished: @escaping CompletionHandler)
    func cancel()
}
extension ImageURLRequest {
    init(url: URL, timeout: TimeInterval = 15, client: HTTPClient = URLSession.shared) {
        self.init(url: url, timeout: timeout, client: client)
    }
}

final class ImageRequest: ImageURLRequest {
    
    private var task: HTTPClientTask?
    private let urlRequest: URLRequest
    private let client: HTTPClient
    
    var url: URL {
        urlRequest.url!
    }
    var isCancelled: Bool {
        task == nil || task!.isCancelled
    }
    
    init(url: URL, timeout: TimeInterval, client: HTTPClient) {
        self.urlRequest = URLRequest(url: url, timeoutInterval: timeout)
        self.client = client
    }
    
    func start(_ finished: @escaping CompletionHandler) {
        print("\n+++ Start loading image from \(urlRequest)...")
        let _urlRequest = urlRequest
        task = client.fetch(request: urlRequest) {[weak self] result in
            guard let self else {return}
            guard _urlRequest == urlRequest else {
                print("\n--- Different urls")
                finished(nil)
                return
            }
            switch result {
            case let .success((data, _)):
                if let image = UIImage(data: data) {
                    print("\n+++ Image from URL: \(_urlRequest) has loaded")
                    finished(image)
                } else {
                    print("\n--- Invalid image data")
                    finished(nil)
                }
            case let .failure(error):
                print("\n--- Error: \(error.localizedDescription)")
                finished(nil)
            case .cancelled:
                print("\n--- Image loading operation \(_urlRequest) is cancelled")
                finished(nil)
            }
        }
        task!.start()
    }
    func cancel() {
        task?.stop()
        task = nil
    }
}
extension ImageRequest {
    static func == (lhs: ImageRequest, rhs: ImageRequest) -> Bool {
        lhs.urlRequest == rhs.urlRequest
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(urlRequest)
    }
}
extension ImageRequest: CustomStringConvertible {
    var description: String {
        "url: \(url)"
    }
}