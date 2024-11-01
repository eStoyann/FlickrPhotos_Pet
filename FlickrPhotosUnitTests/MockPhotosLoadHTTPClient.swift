//
//  MockPhotosLoadHTTPClient.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 29.10.2024.
//
import Foundation
import SimpleNetworkKit
import DomainModels

final class MockPhotosLoadHTTPClient: HTTPClient {
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
                let pageInfo = flickrPage()
                let photosResponse = FlickrResponse(page: pageInfo)
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
                    let pageInfo = flickrPage()
                    let httpResponse = httpResponse(url: request.url!)
                    let data = encode(data: pageInfo)
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
