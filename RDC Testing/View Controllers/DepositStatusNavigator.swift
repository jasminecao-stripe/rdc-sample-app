//
//  DepositStatusNavigator.swift
//  RDC Testing
//
//  Created by Tim Isenman on 6/11/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation

/// Delegate to allow view controllers to pop back to edit a deposit or reset and start over completely.
protocol DepositStatusNavigator: AnyObject {
    func popToRoot()
    func startOver()
}
