//
//  PhotosViewModelProtocol.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 31.10.2024.
//
import UIKit

protocol PhotosViewModelProtocol {
    var title: String {get}
    var searchBarPlaceholder: String {get}
    var photosSearchTermsHistoryViewModel: PhotosSearchTermsHistoryViewModel {get}
    var selectedSearchTerm: Publisher<String?>{get}
    var loadNextPhotosPageOperationStatus: Publisher<OperationStatus<Array<IndexPath>,Error>>{get}
    var loadRecentPhotosOperationStatus: Publisher<OperationStatus<Bool,Error>>{get}
    
    func getPhotos()
}
