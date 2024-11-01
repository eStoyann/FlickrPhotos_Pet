//
//  FlickrResponse.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation

public struct FlickrResponse: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case page = "photos"
    }
    public struct Page: Codable, Sendable {
        public typealias Photos = Array<Photo>
        public struct Photo: Codable, Sendable {
            public let id: String
            public let farm: Int
            public let secret: String
            public let server: String
            
            public init(id: String, farm: Int, secret: String, server: String) {
                self.id = id
                self.farm = farm
                self.secret = secret
                self.server = server
            }
        }
        enum CodingKeys: String, CodingKey {
            case current = "page"
            case total = "pages"
            case size = "perpage"
            case photos = "photo"
            case totalPhotos = "total"
        }
        public let current: Int
        public let size: Int
        public let total: Int
        public var next: Int? {
            current+1 <= total ? current+1 : nil
        }
        public let totalPhotos: Int
        public let photos: Photos
        
        public init(current: Int, size: Int, total: Int, totalPhotos: Int, photos: Photos) {
            self.current = current
            self.size = size
            self.total = total
            self.totalPhotos = totalPhotos
            self.photos = photos
        }
    }
    public let page: Page
    
    public init(page: Page) {
        self.page = page
    }
}
extension FlickrResponse {
    public func new(by photos: Page.Photos) -> FlickrResponse {
        let page = Page(current: page.current,
                        size: page.size,
                        total: page.total,
                        totalPhotos: page.totalPhotos,
                        photos: photos)
        return .init(page: page)
    }
}

