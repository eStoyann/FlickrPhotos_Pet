//
//  PhotoCollectionViewCell.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 16
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.tintColor = .gray
        }
    }
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopActivityIndicatorView()
        photoImageView.image = nil
    }
    
    func setup(image: UIImage) {
        photoImageView.image = image
    }
    func stopActivityIndicatorView() {
        activityIndicatorView.stopAnimating()
    }
    func startActivityIndicatorView() {
        activityIndicatorView.startAnimating()
    }
}
