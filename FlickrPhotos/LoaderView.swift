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
    private var animator = Animator()
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
        let config = LoaderViewAnimationFactory.Configuration(duration: duration, delay: delay)
        let animation = LoaderViewAnimationFactory.present(view: self, config: config).animation
        animator
            .add(animation)
            .run(completion)
    }
    func stopAnimation(duration: TimeInterval = 0.25,
                       delay: Double = 0,
                       _ completion: (() -> Void)? = nil) {
        guard spinner.isAnimating else {return}
        let config = LoaderViewAnimationFactory.Configuration(duration: duration, delay: delay)
        let animation = LoaderViewAnimationFactory.hide(view: self, config: config).animation
        animator
            .add(animation)
            .run {[weak self] _ in
            self?.spinner.stopAnimating()
            self?.removeFromSuperview()
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








