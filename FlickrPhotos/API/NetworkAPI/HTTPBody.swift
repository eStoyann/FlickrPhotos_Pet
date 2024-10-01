//
//  HTTPBody.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 01.10.2024.
//

import Foundation

protocol HTTPBody {
    func encode() throws -> Data
}

class DefaultHTTPBody: HTTPBody {
    private let parameters: [String: Any]
    private let options: JSONSerialization.WritingOptions
    
    init(parameters: [String: Any],
         options: JSONSerialization.WritingOptions = []) {
        self.parameters = parameters
        self.options = options
    }
    
    func encode() throws -> Data {
        try JSONSerialization.data(withJSONObject: parameters,
                                   options: options)
    }
}
