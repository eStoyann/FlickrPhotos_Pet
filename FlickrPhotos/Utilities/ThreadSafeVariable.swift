//
//  ThreadSafeVariable.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import Foundation

final class ThreadSafeVariable<T> {
    
    private var val: T
    private let queue = DispatchQueue(label: "thread_safe_queue",
                                      attributes: .concurrent)
    var value: T {
        get {
            queue.sync {
                return val
            }
        }
        set {
            queue.async(flags: .barrier){
                self.val = newValue
            }
        }
    }
    init(_ val: T) {
        self.val = val
    }
}
extension ThreadSafeVariable: CustomStringConvertible {
    var description: String {
        "\(val)"
    }
}
