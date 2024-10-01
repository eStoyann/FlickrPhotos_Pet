//
//  PhotosResponse.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation

struct PhotosResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case pageInfo = "photos"
    }
    struct PageInfo: Codable {
        enum CodingKeys: String, CodingKey {
            case currentPage = "page"
            case totalPages = "pages"
            case pageSize = "perpage"
            case photos = "photo"
            case totalPhotos = "total"
        }
        private let currentPage: Int
        private let pageSize: Int
        
        let totalPages: Int
        let totalPhotos: Int
        let photos: Photos
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            currentPage = try container.decode(Int.self, forKey: .currentPage)
            pageSize = try container.decode(Int.self, forKey: .pageSize)
            totalPages = try container.decode(Int.self, forKey: .totalPages)
            totalPhotos = try container.decode(Int.self, forKey: .totalPhotos)
            photos = try container.decode(Photos.self, forKey: .photos)
        }
    }
    let pageInfo: PageInfo
    var searchTerm: String?
}
extension PhotosResponse.PageInfo {
    var nextPage: Int? {
        page.number+1 <= totalPages ? page.number+1 : nil
    }
    var page: Page {
        Page(number: currentPage, size: pageSize)
    }
    
    init(currentPage: Int, pageSize: Int, totalPages: Int, totalPhotos: Int, photos: Photos) {
        self.currentPage = currentPage
        self.pageSize = pageSize
        self.totalPages = totalPages
        self.totalPhotos = totalPhotos
        self.photos = photos
    }
}
extension PhotosResponse {
    func new(forNewPhotos photos: Photos) -> PhotosResponse {
        let newPageInfo = PhotosResponse.PageInfo(currentPage: pageInfo.page.number,
                                                  pageSize: pageInfo.page.size,
                                                  totalPages: pageInfo.totalPages,
                                                  totalPhotos: pageInfo.totalPhotos,
                                                  photos: photos)
        return .init(pageInfo: newPageInfo)
    }
}

