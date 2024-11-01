//
//  Extension+Error.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 23.07.2024.
//

import Foundation
import SimpleNetworkKit

extension Error {
    var isURLRequestCancelled: Bool {
        code == NSURLErrorCancelled
    }
}
