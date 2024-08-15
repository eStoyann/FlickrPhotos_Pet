//
//  Photo.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation

typealias Photos = Array<Photo>
struct Photo: Codable {
    let id : String
    let farm : Int
    let secret : String
    let server : String
}
