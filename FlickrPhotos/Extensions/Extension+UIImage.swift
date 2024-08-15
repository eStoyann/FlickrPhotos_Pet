//
//  Extension+UIImage.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 19.07.2024.
//

import Foundation
import UIKit

extension UIImage {
    static let placeholder: UIImage = {
        let image = UIImage(systemName: "photo")!
        image.withRenderingMode(.alwaysTemplate)
        return image
    }()
}
