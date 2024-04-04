//
//  AccountFeaturesResponse.swift
//  RDC Testing
//
//  Created by Tim Isenman on 5/31/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation

/// The response body from Stripe that tells us which features a financial account has access to.
struct AccountFeaturesResponse: Decodable {
    let object: String
    let activeFeatures: [String]
}
