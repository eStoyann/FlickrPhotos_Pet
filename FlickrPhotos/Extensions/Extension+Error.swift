//
//  Extension+Error.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 23.07.2024.
//

import Foundation

extension Error {
    var ns: NSError {
        self as NSError
    }
}
