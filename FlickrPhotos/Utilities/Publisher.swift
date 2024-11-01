//
//  Publisher.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation

class Publisher<Value> where Value: Equatable {
    typealias Observer = (Value) -> Void
    
    //MARK: - Private properties
    private var observer: Observer?
    
    //MARK: - Public properties
    public var value: Value {
        didSet {
            if oldValue != value {
                observer?(value)
            }
        }
    }
    //MARK: - Lifecycle
    init(_ value: Value) {
        self.value = value
    }
    //MARK: - Public methods
    func bind(_ observer: @escaping Observer) {
        self.observer = observer
    }
}
