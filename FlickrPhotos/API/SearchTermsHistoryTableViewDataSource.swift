//
//  SearchTermsHistoryTableViewDataSource.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 18.07.2024.
//

import Foundation
import UIKit

final class SearchTermsHistoryTableViewDataSource: NSObject,
                                                         UITableViewDelegate,
                                                         UITableViewDataSource {
    
    private let source: PhotosSearchTermsHistoryDataSource
    private let heightForSearchTerm: CGFloat = 40
    
    init?(source: PhotosSearchTermsHistoryDataSource?) {
        if let source {
            self.source = source
        } else {
            return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        source.numberOfSectionsOfSearchTerms
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        source.numberOfSearchTerms(in: section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTermTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let searchText = source.searchTerm(at: indexPath)
        cell.set(searchText: searchText)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        source.didSelectSearchTerm(at: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        max(UITableView.automaticDimension, heightForSearchTerm)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForSearchTerm
    }
}
