//
//  Protocol+NibLoadableView.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 19.07.2024.
//

import Foundation

protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}
extension NibLoadableView where Self: NSObject {
    static var nibName: String {
        String(describing: self)
    }
}
