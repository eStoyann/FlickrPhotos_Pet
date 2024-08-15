//
//  PhotosResponse.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation

struct PhotosResponse: Codable {
    struct PageInfo: Codable {
        enum CodingKeys: String, CodingKey {
            case currentPage = "page"
            case totalPages = "pages"
            case pageSize = "perpage"
            case photos = "photo"
            case totalPhotos = "total"
        }
        let currentPage: Int
        let totalPages: Int
        let pageSize: Int
        let totalPhotos: Int
        let photos: [Photo]
    }
    enum CodingKeys: String, CodingKey {
        case pageInfo = "photos"
    }
    let pageInfo: PageInfo
    var searchTerm: String?
}
extension PhotosResponse.PageInfo {
    var nextPage: Int? {
        currentPage+1 <= totalPages ? currentPage+1 : nil
    }
}


