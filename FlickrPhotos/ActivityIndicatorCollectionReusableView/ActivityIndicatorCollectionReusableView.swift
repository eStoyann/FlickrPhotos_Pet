//
//  ActivityIndicatorCollectionReusableView.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 18.07.2024.
//

import UIKit

class ActivityIndicatorCollectionReusableView: UICollectionReusableView {

    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopActivityIndicator()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func startActivityIndicator() {
        activityIndicatorView.startAnimating()
    }
    func stopActivityIndicator() {
        activityIndicatorView.stopAnimating()
    }
}
