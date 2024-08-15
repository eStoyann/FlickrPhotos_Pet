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
    private(set) var isAnimating = false
    
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
                        _ completion: (() -> Void)? = nil) {
        guard !isAnimating else { return }
        isAnimating = true
        spinner.startAnimating()
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: .curveEaseInOut) {
            self.alpha = 1
        } completion: { _ in
            completion?()
        }
    }
    func stopAnimation(duration: TimeInterval = 0.25,
                       delay: Double = 0,
                       _ completion: (() -> Void)? = nil) {
        guard isAnimating else { return }
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: .curveEaseInOut) {
            self.alpha = 0
        } completion: {[weak self] _ in
            self?.spinner.stopAnimating()
            self?.isAnimating = false
            self?.removeFromSuperview()
            completion?()
        }
    }
    
    //MARK: - Private method
    private func setupUI() {
        isUserInteractionEnabled = true
        addSubview(blurView)
        addSubview(spinner)
        alpha = 0
    }
}




