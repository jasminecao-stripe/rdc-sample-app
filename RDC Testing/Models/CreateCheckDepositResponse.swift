//
//  CheckDepositCreationRequest.swift
//  RDC Testing
//
//  Created by Tim Isenman on 5/31/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation

/// The response body when initiating a Check Deposit with Stripe
struct CreateCheckDepositResponse: Decodable {
    let id: String
    let object: String
    var checkDetails: String?
    let livemode: Bool
    let created: Double
    let financialAccount: String
    let status: String
}
