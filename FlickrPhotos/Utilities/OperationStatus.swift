//
//  OperationStatus.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 28.10.2024.
//
import Foundation

enum OperationStatus<Success, Failure>: Equatable where Success: Equatable,
                                                        Failure: Error {
    case idle
    case performing
    case performed(Success)
    case failed(Failure)
    
    var inProgress: Bool {
        if case .performing = self {return true}
        return false
    }
    
    static func == (lhs: OperationStatus<Success, Failure>,
                    rhs: OperationStatus<Success, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (let .performed(success1),
              let .performed(success2)):
            return success1 == success2
        case (.idle,.idle):
            return true
        case (.performing, .performing):
            return true
        case (let .failed(error1),
              let .failed(error2)):
            return error1.domain == error2.domain && error1.code == error2.code
        default:
            return false
        }
    }
}
extension OperationStatus {
    static var publisher: Publisher<OperationStatus> {
        Publisher(.idle)
    }
}
