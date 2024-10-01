//
//  Extension+String.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

extension String {
    var ns: NSString {
        self as NSString
    }
    var isNotEmpty: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension URL {
    var string: NSString {
        absoluteString.ns
    }
}
