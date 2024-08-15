//
//  MockImageRequestHTTPClient.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 24.07.2024.
//

import Foundation
import UIKit
@testable import FlickrPhotos

class MockImageRequestHTTPClient: HTTPClient {
    enum Errors: LocalizedError {
        case invalidData
    }
    
    enum Status {
        case success
        case failure
    }
    
    let status: Status
    
    init(status: Status) {
        self.status = status
    }
    
    func fetch(request: URLRequest, _ finished: @escaping CompletionHandler) -> HTTPClientTask {
        let task = URLSession.shared.fetch(request: request) {[weak self] result in
            guard let self else {return}
            switch status {
            case .success:
                let data = UIImage.placeholder.jpegData(compressionQuality: 0.25) ?? Data(count: 0)
                let httpResponse = httpResponse(url: request.url!)
                finished(.success((data, httpResponse)))
            case .failure:
                finished(.failure(Errors.invalidData))
            }
        }
        task.start()
        return task
    }
    
    private func httpResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: url,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}
