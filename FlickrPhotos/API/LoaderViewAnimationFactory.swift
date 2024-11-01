//
//  LoaderViewAnimationFactory.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 31.10.2024.
//
import UIKit

enum LoaderViewAnimationFactory: AnimationFactory {
    struct Configuration {
        let duration: TimeInterval
        let delay: TimeInterval
        
        init(duration: TimeInterval = 0.5, delay: TimeInterval = 0) {
            self.duration = duration
            self.delay = delay
        }
    }
    case present(view: UIView, config: Configuration)
    case hide(view: UIView, config: Configuration)
    
    var animation: Animator.Animation {
        switch self {
        case let .present(view, config):
            return { finished in
                UIView.animate(withDuration: config.duration,
                               delay: config.delay,
                               options: .curveEaseInOut) {
                    view.alpha = 1
                } completion: { isFinished in
                    finished?(isFinished)
                }
            }
        case let .hide(view, config):
            return { finished in
                UIView.animate(withDuration: config.duration,
                               delay: config.delay,
                               options: .curveEaseInOut) {
                    view.alpha = 0
                } completion: { isFinished in
                    finished?(isFinished)
                }
            }
        }
    }
}
