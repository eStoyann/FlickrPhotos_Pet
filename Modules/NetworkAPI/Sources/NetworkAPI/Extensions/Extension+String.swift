//
//  Extension+String.swift
//  NetworkAPI
//
//  Created by Evgeniy Stoyan on 29.10.2024.
//
//
import Foundation

extension String {
    var ns: NSString {
        self as NSString
    }
    var isNotEmpty: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

