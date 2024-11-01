//
//  MockFlickrPhotosHTTPClient.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import Foundation
import SimpleNetworkKit
import DomainModels
@testable import NetworkAPI

final class MockFlickrPhotosHTTPClient: HTTPClient {
    enum Errors: LocalizedError {
        case responseFailure
        case decodingFailure
        case decodedFailureResponse
        case invalidHTTPResponse
    }
    enum Status {
        case success
        case failure(Errors)
    }
    
    let status: Status

    init(status: Status) {
        self.status = status
    }
    
    func fetch(request: URLRequest,
              _ finished: @escaping CompletionHandler) -> SimpleNetworkKit.HTTPClientTask {
        let url = URL(string: "https://test")!
        let mockURLRequest = URLRequest(url: url)
        let task = URLSession
            .shared
            .fetch(request: mockURLRequest) {[weak self] _ in
            guard let self else {return}
            switch status {
            case .success:
                let httpResponse = httpResponse(url: request.url!)
                let page = flickrPage()
                let photosResponse = FlickrResponse(page: page)
                let data = encode(data: photosResponse)
                finished(.success((data, httpResponse)))
            case let .failure(error):
                switch error {
                case .invalidHTTPResponse:
                    let httpResponse = httpResponse(url: request.url!, statusCode: 404)
                    let data = Data(count: 0)
                    finished(.success((data, httpResponse)))
                case .responseFailure:
                    finished(.failure(error))
                case .decodedFailureResponse:
                    let httpResponse = httpResponse(url: request.url!)
                    let failure = Failure(code: 404,
                                          message: "Failure response",
                                          stat: "bad")
                    let response = Response<FlickrResponse>.failure(failure)
                    let data = encode(data: response)
                    finished(.success((data, httpResponse)))
                case .decodingFailure:
                    let page = flickrPage()
                    let httpResponse = httpResponse(url: request.url!)
                    let data = encode(data: page)
                    finished(.success((data, httpResponse)))
                }
            }
        }
        return task
    }
    private func encode(data: Codable) -> Data {
        try! JSONEncoder().encode(data)
    }
    private func httpResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: url,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
    private func flickrPage() -> FlickrResponse.Page {
        let photo = FlickrResponse.Page.Photo(id: "", farm: 0, secret: "", server: "")
        let photos = Array(repeating: photo, count: 10000)
        return FlickrResponse.Page(current: 1,
                                   size: 10,
                                   total: 100,
                                   totalPhotos: photos.count,
                                   photos: photos)
    }
}
