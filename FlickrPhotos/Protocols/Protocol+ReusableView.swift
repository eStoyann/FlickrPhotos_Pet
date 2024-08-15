//
//  Protocol+ReusableView.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 19.07.2024.
//

import Foundation

protocol ReusableView: AnyObject {
    static var identifier: String { get }
}
extension ReusableView where Self: NSObject {
    static var identifier: String {
        String(describing: self)
    }
}
