//
//  StripeAPIError.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/9/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation

/// A type representing an error response that the Stripe API can return with some errors.
struct StripeAPIErrorResponse: Codable {
    struct APIError: Codable {
        let message: String
        let type: String
    }
    
    let error: APIError
}
