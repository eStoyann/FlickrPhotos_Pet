//
//  Response.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation

enum Response<Success>: Codable where Success: Codable {
    case success(Success)
    case failure(Failure)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .success(try container.decode(Success.self))
        } catch {
            self = .failure(try container.decode(Failure.self))
        }
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .success(response):
            try container.encode(response)
        case let .failure(failure):
            try container.encode(failure)
        }
    }
}
struct Failure: LocalizedError {
    let message: String
    let stat: String
    let code: Int
    var errorDescription: String? {
        message
    }

    init(code: Int, message: String, stat: String) {
        self.code = code
        self.message = message
        self.stat = stat
    }
}
extension Failure: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
        self.code = try container.decode(Int.self, forKey: .code)
        self.stat = try container.decode(String.self, forKey: .stat)
    }
}
