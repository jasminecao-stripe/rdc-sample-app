//
//  CheckImageUploadResponse.swift
//  RDC Testing
//
//  Created by Tim Isenman on 6/1/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation

/// The response object from a request to upload a check.
struct CheckImageUploadResponse: Decodable {
    let id: String
    let object: String?
    let created: Double
    let expiresAt: Double
    let filename: String?
    let links: Links?
    let purpose: String?
    let size: Double?
    let title: String?
    let type: String?
    let url: String?
}

struct Links: Decodable {
    var object: String?
    var data: [StripeImageData]?
}

struct StripeImageData: Decodable {
    let id: String
    let object: String?
    let created: Double?
    let expired: Bool
    let expiresAt: Double?
    let file: String?
    let livemode: Bool
    let url: String?
}
