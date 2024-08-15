//
//  State.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 14.08.2024.
//

import Foundation

enum State<Success>: Equatable where Success: Equatable {
    case idle
    case loading
    case loaded(Success)
    case failure(Error)
    
    static func == (lhs: State<Success>, rhs: State<Success>) -> Bool {
        switch (lhs, rhs) {
        case (let .loaded(success1), 
              let .loaded(success2)):
            return success1 == success2
        case (.idle,.idle):
            return true
        case (.loading, .loading):
            return true
        case (let .failure(error1), 
              let .failure(error2)):
            let err1 = error1 as NSError
            let err2 = error2 as NSError
            return err1.domain == err2.domain && err1.code == err2.code
        default:
            return false
        }
    }
}
