//
//  PhotosSearchTermsDelegate.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 31.10.2024.
//
import Foundation

protocol PhotosSearchTermsDelegate {
    func search(for searchTerm: String)
    func cleanSelectedSearchTerm()
}
