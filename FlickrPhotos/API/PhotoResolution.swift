//
//  PhotoResolution.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 01.10.2024.
//

import Foundation

enum PhotoResolution: String {
    case s/*    thumbnail    75    cropped square*/
    case q/*    thumbnail    150    cropped square*/
    case t/*    thumbnail    100*/
    case m/*    small    240*/
    case n/*    small    320*/
    case w/*    small    400*/
    case `default` = ""/*    medium    500*/
    case z/*    medium    640*/
    case c/*    medium    800*/
    case b/*    large    1024*/
    
    var value: CGFloat {
        switch self {
        case .s: return 75
        case .q: return 150
        case .t: return 100
        case .m: return 240
        case .n: return 320
        case .default: return 500
        case .w: return 400
        case .z: return 640
        case .c: return 800
        case .b: return 1024
        }
    }
    var path: String {
        self == .default ? "" : "_\(rawValue)"
    }
}
