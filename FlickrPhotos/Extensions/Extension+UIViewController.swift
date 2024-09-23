//
//  Extension+UIViewController.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation
import UIKit

extension UIViewController: NibLoadableView {
    static func loadFromNib<VC>() -> VC where VC: UIViewController {
        VC(nibName: VC.nibName, bundle: .main)
    }
}
