//
//  SearchTermsHistoryStorage.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import Foundation

protocol SearchTermsHistoryStorage {
    var searchTerms: Array<String>{get}
    
    func save(searchTerm: String)
    func remove(searchTerm: String)
    func removeAll()
}

final class SearchTermsHistoryLocalStorage: SearchTermsHistoryStorage {
    private enum Keys: String {
        case term = "search_term_for_local_storage"
    }
    
    private let termsLimit: Int
    private let storage = UserDefaults.standard
    private(set) var searchTerms: Array<String> {
        get {
            (storage.value(forKey: Keys.term.rawValue) as? Array<String>) ??  []
        }
        set {
            if !newValue.isEmpty {
                storage.set(newValue, forKey: Keys.term.rawValue)
            } else {
                storage.removeObject(forKey: Keys.term.rawValue)
            }
        }
    }
    
    init(searchTermsLimit: UInt = 10) {
        self.termsLimit = Int(searchTermsLimit)
    }
    
    func save(searchTerm: String) {
        if findIndex(of: searchTerm) == nil {
            if searchTerms.count >= termsLimit {
                searchTerms.removeLast()
            } 
            searchTerms.insert(searchTerm, at: 0)
        }
    }
    func remove(searchTerm: String) {
        if let index = findIndex(of: searchTerm) {
            searchTerms.remove(at: index)
        }
    }
    func removeAll() {
        searchTerms = []
    }
}
private extension SearchTermsHistoryLocalStorage {
    func findIndex(of searchTerm: String) -> Int? {
        searchTerms.firstIndex(where: {$0.lowercased() == searchTerm.lowercased()})
    }
}
