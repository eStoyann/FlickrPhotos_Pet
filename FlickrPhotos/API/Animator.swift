//
//  Animator.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 31.10.2024.
//
import Foundation

class Animator {
    typealias Completion = (Bool) -> Void
    typealias Animation = (Completion?) -> Void
    private var animations = [Animation]()
    private(set) var isAnimating = false
    
    func add(_ animations: Animation...) -> Animator {
        self.animations.append(contentsOf: animations)
        return self
    }
    
    func run(_ completion: Completion?) {
        guard !isAnimating else {return}
        run(animations.first, completion)
    }
    
    deinit {
        animations = []
    }
}
private extension Animator {
    func run(_ animation: Animation?, _ completion: Completion?) {
        guard let animation else {
            isAnimating = false
            completion?(true)
            return
        }
        isAnimating = true
        animation {[weak self] isFinished in
            guard let self else {return}
            if isFinished {
                self.animations = Array(animations.dropFirst())
                self.run(animations.first, completion)
            } else {
                self.isAnimating = false
                completion?(isFinished)
            }
        }
    }
}
