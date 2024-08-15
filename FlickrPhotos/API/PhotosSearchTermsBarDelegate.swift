//
//  PhotosSearchTermsBarDelegate.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 18.07.2024.
//

import Foundation
import UIKit

final class PhotosSearchTermsBarDelegate: NSObject,
                                    UISearchBarDelegate {
    
    private let source: PhotosSearchTermsDelegate
    
    init?(source: PhotosSearchTermsDelegate?) {
        if let source {
            self.source = source
        } else {
            return nil
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        source.cleanSelectedSearchTerm()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.isNotEmpty == true {
            source.search(for: searchBar.text!)
        }
        searchBar.resignFirstResponder()
    }
}
