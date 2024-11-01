//
//  StoreSearchTermUseCase.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 30.10.2024.
//
import Foundation

protocol StoreSearchTermUseCase {
    func execute(_ searchTerm: String)
}
struct SaveSearchTermUseCase: StoreSearchTermUseCase {
    private let repo: SearchTermsRepository
    
    init(repo: SearchTermsRepository) {
        self.repo = repo
    }
    func execute(_ searchTerm: String) {
        repo.save(searchTerm)
    }
}
