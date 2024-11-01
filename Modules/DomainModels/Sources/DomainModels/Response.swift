//
//  Response.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation

public enum Response<Success>: Codable where Success: Codable {
    case success(Success)
    case failure(Failure)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .success(try container.decode(Success.self))
        } catch {
            self = .failure(try container.decode(Failure.self))
        }
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .success(response):
            try container.encode(response)
        case let .failure(failure):
            try container.encode(failure)
        }
    }
}
public struct Failure: LocalizedError {
    public let message: String
    public let stat: String
    public let code: Int
    public var errorDescription: String? {
        message
    }

    public init(code: Int, message: String, stat: String) {
        self.code = code
        self.message = message
        self.stat = stat
    }
}
extension Failure: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
        self.code = try container.decode(Int.self, forKey: .code)
        self.stat = try container.decode(String.self, forKey: .stat)
    }
}
