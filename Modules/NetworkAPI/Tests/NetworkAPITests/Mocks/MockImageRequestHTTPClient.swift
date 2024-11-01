//
//  MockImageRequestHTTPClient.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 24.07.2024.
//

import Foundation
import SimpleNetworkKit
import UIKit
@testable import NetworkAPI

final class MockImageRequestHTTPClient: HTTPClient {
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
    
    func fetch(request: URLRequest,
               _ finished: @escaping CompletionHandler) -> HTTPClientTask {
        let task = URLSession.shared.fetch(request: request) {[weak self] result in
            guard let self else {return}
            switch status {
            case .success:
                let data = UIImage(systemName: "photo")?.jpegData(compressionQuality: 0.25) ?? Data()
                if data.count == 0 {
                    print(data.count)
                }
                let httpResponse = HTTPURLResponse(url: request.url!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)!
                finished(.success((data, httpResponse)))
            case .failure:
                finished(.failure(Errors.invalidData))
            }
        }
        task.start()
        return task
    }
}
