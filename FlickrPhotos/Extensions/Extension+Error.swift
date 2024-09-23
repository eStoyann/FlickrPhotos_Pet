//
//  Extension+Error.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 23.07.2024.
//

import Foundation

extension Error {
    private var ns: NSError {
        self as NSError
    }
    var code: Int {
        ns.code
    }
    var isURLRequestCancelled: Bool {
        ns.code == NSURLErrorCancelled
    }
    var isInternetConnectionLost: Bool {
        ns.code == NSURLErrorNotConnectedToInternet
    }
}
