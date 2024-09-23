//
//  LoaderView.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 19.07.2024.
//

import Foundation
import UIKit

class LoaderView: UIView {
    
    //MARK: - Private property
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return effectView
    }()
    private lazy var spinner: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.style = .medium
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    //MARK: - Public methods
    func startAnimation(duration: TimeInterval = 0.25,
                        delay: Double = 0,
                        _ completion: ((Bool) -> Void)? = nil) {
        guard !spinner.isAnimating else {return}
        spinner.startAnimating()
        let animation = LoaderViewAnimationFactory.present(view: self,
                                                           duration: duration,
                                                           delay: delay).animation
        animation.run(completion)
    }
    func stopAnimation(duration: TimeInterval = 0.25,
                       delay: Double = 0,
                       _ completion: (() -> Void)? = nil) {
        guard spinner.isAnimating else {return}
        let animation = LoaderViewAnimationFactory.hide(view: self,
                                                        duration: duration,
                                                        delay: delay).animation
        animation.run {[weak self] _ in
            self?.spinner.stopAnimating()
            completion?()
        }
        
    }
    
    //MARK: - Private method
    private func setupUI() {
        isUserInteractionEnabled = true
        addSubviews(blurView, spinner)
        alpha = 0
    }
}
extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
}







protocol AnimationFactory {
    var animation: Animation {get}
}


enum LoaderViewAnimationFactory: AnimationFactory {
    case present(view: UIView, duration: CGFloat, delay: CGFloat)
    case hide(view: UIView, duration: CGFloat, delay: CGFloat)
    
    var animation: Animation {
        switch self {
        case let .present(view, duration, delay):
            return Animation { finished in
                UIView.animate(withDuration: duration,
                               delay: delay,
                               options: .curveEaseInOut) {
                    view.alpha = 1
                } completion: { isFinished in
                    finished?(isFinished)
                }
            }
        case let .hide(view, duration, delay):
            return Animation { finished in
                UIView.animate(withDuration: duration,
                               delay: delay,
                               options: .curveEaseInOut) {
                    view.alpha = 0
                } completion: { isFinished in
                    finished?(isFinished)
                    view.removeFromSuperview()
                }
            }
        }
    }
}

class Animation {
    typealias Completion = (Bool) -> Void
    typealias Body = (Completion?) -> Void
    
    private let body: Body
    private let id = UUID()
    private(set) var isAnimating = false
    private var previous: Animation?
    private var next: Animation?
    private var isLast: Bool {
        next == nil
    }
    private var isFirst: Bool {
        previous == nil
    }
    
    init(_ body: @escaping Body) {
        self.body = body
    }
    
    func combine(with animation: Animation) -> Animation {
        if !isLast {
            _ = next!.combine(with: animation)
        } else {
            next = animation
            next!.previous = self
        }
        return self
    }
    func run(_ completion: Completion?) {
        if !isAnimating {
            isAnimating = true
            body {[weak self] isFinished in
                guard let self else {return}
                if isFinished && self.next != nil {
                    self.next?.run {
                        self.isAnimating = false
                        completion?($0)
                        self.previous = nil
                        self.next = nil
                    }
                } else {
                    isAnimating = false
                    completion?(isFinished)
                }
            }
        }
    }
    
    deinit {
        print(String(describing: self))
    }
}
extension Animation: CustomStringConvertible{
    var description: String {
        "Animation(\(id))"
    }
}

