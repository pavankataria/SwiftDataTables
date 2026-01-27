//
//  AppDelegate.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 03/09/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureNavigationBarAppearance()

        let window = UIWindow(frame: UIScreen.main.bounds)
        let instance = MenuViewController()
        self.navigationController = UINavigationController(rootViewController: instance)
        window.rootViewController = self.navigationController
        self.window = window
        window.makeKeyAndVisible()
        return true
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
