//
//  Extension+UIScrollView.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 01.11.2024.
//
import UIKit

extension UIScrollView {
    func scrollToTop(animated: Bool = true) {
        setContentOffset(CGPoint(x: 0, y: -safeAreaInsets.top), animated: animated)
    }
}
