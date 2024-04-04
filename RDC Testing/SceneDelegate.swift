//
//  SceneDelegate.swift
//  RDC Testing
//
//  Created by Brian Capps on 5/17/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = StripeNavigationController(rootViewController: CheckDepositViewController())
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
