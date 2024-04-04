//
//  StripeNavigationController.swift
//  RDC Testing
//
//  Created by Tim Isenman on 6/11/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

/// A `UINavigationController` that only supports portrait orientation.
final class StripeNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
