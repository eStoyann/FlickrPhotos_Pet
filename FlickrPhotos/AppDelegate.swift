//
//  AppDelegate.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private lazy var appManager = AppManager(window: window)
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appManager.presentPhotosViewController()
        return true
    }
}
