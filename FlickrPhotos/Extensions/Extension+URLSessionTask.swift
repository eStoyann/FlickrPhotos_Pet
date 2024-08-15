//
//  Extension+URLSessionTask.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

protocol HTTPClientTask {
    var isCancelled: Bool {get}
    func stop()
    func start()
}
extension URLSessionTask: HTTPClientTask {
    func stop() {
        cancel()
    }
    func start() {
        resume()
    }
    var isCancelled: Bool {
        state == .canceling
    }
}
