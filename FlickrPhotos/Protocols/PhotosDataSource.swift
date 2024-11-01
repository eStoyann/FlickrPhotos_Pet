//
//  PhotosDataSource.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 31.10.2024.
//
import UIKit

protocol PhotosDataSource {
    var numberOfSectionsOfPhotos: Int{get}
    
    func numberOfPhotos(in section: Int) -> Int
    func startLoadingImage(at indexPath: IndexPath, _ finished: @escaping (UIImage?) -> Void)
    func isLoadingImage(at indexPath: IndexPath) -> Bool
    func stopLoadingImage(at indexPath: IndexPath)
    func loadNextPhotosPage()
}
extension PhotosDataSource {
    var numberOfSectionsOfPhotos: Int{1}
}
