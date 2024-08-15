//
//  Extension+URLSession.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation
import UIKit

protocol HTTPClient {
    typealias CompletionHandler = (HTTPResult<(Data, HTTPURLResponse), Error>) -> Void
    func fetch(request: URLRequest,
               _ finished: @escaping CompletionHandler) -> HTTPClientTask
}
extension URLSession: HTTPClient {
    func fetch(request: URLRequest, _ finished: @escaping CompletionHandler) -> HTTPClientTask {
        dataTask(with: request) { data, response, error in
            guard error == nil else {
                if error!.ns.code == NSURLErrorCancelled {
                    finished(.cancelled)
                } else {                
                    finished(.failure(error!))
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                finished(.failure(URLError(.badServerResponse)))
                return
            }
            guard let data,
                  !data.isEmpty else {
                finished(.failure(URLError(.dataNotAllowed)))
                return
            }
            finished(.success((data, httpResponse)))
        }
    }
}
