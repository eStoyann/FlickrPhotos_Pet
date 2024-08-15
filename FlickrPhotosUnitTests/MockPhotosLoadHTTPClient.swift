//
//  MockPhotosLoadHTTPClient.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import Foundation
@testable import FlickrPhotos

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
        case cancelled
    }
    
    private let status: Status

    init(options: Status) {
        self.status = options
    }
    
    func fetch(request: URLRequest,
               _ finished: @escaping CompletionHandler) -> HTTPClientTask {
        let url = URL(string: "https://test")!
        let mockURLRequest = URLRequest(url: url)
        let task = URLSession.shared.fetch(request: mockURLRequest) {[weak self] _ in
            guard let self else {return}
            switch status {
            case .success:
                let httpResponse = httpResponse(url: request.url!)
                let pageInfo = pageInfo()
                let photosResponse = PhotosResponse(pageInfo: pageInfo)
                let data = encode(data: photosResponse) ?? Data(count: 0)
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
                    let response = Response<PhotosResponse>.failure(failure)
                    let data = encode(data: response) ?? Data(count: 0)
                    finished(.success((data, httpResponse)))
                case .decodingFailure:
                    let pageInfo = pageInfo()
                    let httpResponse = httpResponse(url: request.url!)
                    let data = encode(data: pageInfo) ?? Data(count: 0)
                    finished(.success((data, httpResponse)))
                }
            case .cancelled:
                finished(.cancelled)
            }
        }
        return task
    }
    private func encode(data: Codable) -> Data? {
        try? Coder().encode(data)
    }
    private func httpResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: url,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
    private func pageInfo() -> PhotosResponse.PageInfo {
        let photo = Photo(id: "", farm: 0, secret: "", server: "")
        let photos = Array(repeating: photo, count: 10000)
        return PhotosResponse.PageInfo(currentPage: 1,
                                       totalPages: 100,
                                       pageSize: 10,
                                       totalPhotos: photos.count,
                                       photos: photos)
    }
}
