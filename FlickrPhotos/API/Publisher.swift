//
//  Publisher.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation

class Publisher<Value> {
    typealias Observer = (Value) -> Void
    
    //MARK: - Private properties
    private var observer: Observer?
    
    //MARK: - Public properties
    public var value: Value {
        didSet {
            observer?(value)
        }
    }
    //MARK: - Lifecycle
    init(initValue: Value) {
        self.value = initValue
    }
    //MARK: - Public methods
    func bind(_ observer: @escaping Observer) {
        self.observer = observer
    }
}
