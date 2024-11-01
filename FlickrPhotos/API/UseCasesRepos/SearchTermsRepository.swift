//
//  SearchTermsRepository.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import Foundation

protocol SearchTermsRepository {
    func save(_ searchTerm: String)
    func fetchSearchTerms() -> [String]
}

struct SearchTermsRepo: SearchTermsRepository {
    private let storage: SearchTermsHistoryStorage
    
    init(storage: SearchTermsHistoryStorage) {
        self.storage = storage
    }
    
    func save(_ searchTerm: String) {
        storage.save(searchTerm: searchTerm)
    }
    func fetchSearchTerms() -> [String] {
        storage.searchTerms
    }
}
