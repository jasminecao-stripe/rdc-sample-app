//
//  InteractionBlockingProgressWindow.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/13/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

/// An indeterminate progress view window overlay that blocks user interaction.
final class InteractionBlockingProgressWindow: UIWindow {
    
    private final class ActivityIndicatorViewController: UIViewController {
        private let activitySpinner = UIActivityIndicatorView(style: .large)
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            activitySpinner.color = UIColor.white
            activitySpinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activitySpinner)
            
            view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            NSLayoutConstraint.activate([
                activitySpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activitySpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            activitySpinner.startAnimating()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            activitySpinner.stopAnimating()
        }
    }
    
    private static let shared = UIApplication.shared.windowScene.map { InteractionBlockingProgressWindow(windowScene: $0) }
    static let animationDuration: TimeInterval = 0.2
    
    // MARK: - UIWindow
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        rootViewController = ActivityIndicatorViewController()
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        windowLevel = .statusBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - ProgressWindow
    
    /// Shows the progress window.
    ///
    /// - Parameter animated: Whether the progress window animates into view. Defaults to `true`.
    static func show(animated: Bool = true) {
        shared?.show(animated: animated)
    }
    
    /// Hides the progress window.
    ///
    /// - Parameter animated: Whether the progress window animates out of view. Defaults to `true`.
    static func hide(animated: Bool = true) {
        shared?.hide(animated: animated)
    }
    
    private func show(animated: Bool) {
        guard let bounds = UIApplication.shared.activeSceneKeyWindow?.bounds else {
            assertionFailure("Could not determine the key window’s bounds.")
            return
        }
        
        frame = bounds
        
        if animated {
            alpha = 0
            
            UIView.animate(withDuration: type(of: self).animationDuration, animations: {
                self.alpha = 1
            })
        }
        
        isHidden = false
    }
    
    private func hide(animated: Bool) {
        if animated {
            UIView.animate(withDuration: type(of: self).animationDuration, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.isHidden = true
                self.alpha = 1
            })
        } else {
            isHidden = true
        }
    }
}

private extension UIApplication {
    var windowScene: UIWindowScene? {
        return connectedScenes.first { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive } as? UIWindowScene
    }
    
    var activeSceneKeyWindow: UIWindow? {
        return windowScene?.windows.first { $0.isKeyWindow }
    }
}
