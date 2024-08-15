//
//  PhotosSearchTermsHistoryViewModel.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 19.07.2024.
//

import Foundation

protocol PhotosSearchTermsHistory {
    var selectedSearchTerm: Publisher<String?>{get}
}

protocol PhotosSearchTermsHistoryDataSource {
    var numberOfSectionsOfSearchTerms: Int{get}
    
    func numberOfSearchTerms(in section: Int) -> Int
    func searchTerm(at indexPath: IndexPath) -> String?
    func didSelectSearchTerm(at indexPath: IndexPath)
}
extension PhotosSearchTermsHistoryDataSource {
    var numberOfSectionsOfSearchTerms: Int{1}
}

final class PhotosSearchTermsHistoryViewModel: PhotosSearchTermsHistory {
    
    private let storage: PhotosSearchTermsHistoryStorage
    
    let selectedSearchTerm = Publisher<String?>(initValue: nil)
    
    init(searchTermsHistoryLocalStorage: PhotosSearchTermsHistoryStorage) {
        self.storage = searchTermsHistoryLocalStorage
    }
}
//MARK: - PhotosSearchTermsHistoryDataSource
extension PhotosSearchTermsHistoryViewModel: PhotosSearchTermsHistoryDataSource {
    func numberOfSearchTerms(in section: Int) -> Int {
        storage.searchTerms.count
    }
    
    func searchTerm(at indexPath: IndexPath) -> String? {
        if numberOfSearchTerms(in: indexPath.section) > indexPath.row {
            return storage.searchTerms[indexPath.row]
        }
        return nil
    }
    func didSelectSearchTerm(at indexPath: IndexPath) {
        if numberOfSearchTerms(in: indexPath.section) > indexPath.row {
            selectedSearchTerm.value = storage.searchTerms[indexPath.row]
        }
    }
}
