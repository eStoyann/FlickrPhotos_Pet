//
//  PhotosSearchTermsHistoryViewModel.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 19.07.2024.
//

import Foundation

protocol PhotosSearchTermsHistory {
    var onSelect: ((String) -> Void)?{get}
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
    struct UseCases {
        let fetchSearchTerms: FetchSearchTermsUseCase
    }
    private let useCases: UseCases
    private var searchTerms: [String] {
        useCases.fetchSearchTerms.execute()
    }
    
    var onSelect: ((String) -> Void)?
    
    init(useCases: UseCases) {
        self.useCases = useCases
    }
}
//MARK: - PhotosSearchTermsHistoryDataSource
extension PhotosSearchTermsHistoryViewModel: PhotosSearchTermsHistoryDataSource {
    func numberOfSearchTerms(in section: Int) -> Int {
        searchTerms.count
    }
    func searchTerm(at indexPath: IndexPath) -> String? {
        if numberOfSearchTerms(in: indexPath.section) > indexPath.row {
            return searchTerms[indexPath.row]
        }
        return nil
    }
    func didSelectSearchTerm(at indexPath: IndexPath) {
        if numberOfSearchTerms(in: indexPath.section) > indexPath.row {
            onSelect?(searchTerms[indexPath.row])
        }
    }
}


protocol FetchSearchTermsUseCase {
    func execute() -> [String]
}
struct RetrieveSearchTermsUseCase: FetchSearchTermsUseCase {
    private let repo: SearchTermsRepository
    
    init(repo: SearchTermsRepository) {
        self.repo = repo
    }
    
    func execute() -> [String] {
        repo.fetchSearchTerms()
    }
}
