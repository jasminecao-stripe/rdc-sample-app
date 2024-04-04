//
//  StripeRequests.swift
//  RDC Testing
//
//  Created by Tim Isenman on 5/31/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation
import UIKit
import Networking

// swiftlint:disable force_unwrapping

let DEFAULT_HEADERS = [
    "Authorization": "Bearer \(K.APIInfo.liveKey)",
    "Stripe-Account": K.APIInfo.account,
    "Stripe-Version": "2020-08-27;financial_accounts_beta=v3;remote_deposit_capture_beta=v1"
]

func loadHeaders(_ newHeaders: [String: String]) -> [String: String] {
    var allHeaders = newHeaders
    allHeaders.merge(DEFAULT_HEADERS) { (current, _) in current }

    return allHeaders
}

/// Allows the app to request which features a given user's account has access to on Stripe
struct FeaturesPerAccountRequest: NetworkRequest {
    
    var baseURL: URL {
        return URL(string: "https://api.stripe.com")!
    }
    
    var path: String {
        return "/v1/financial_accounts/\(K.APIInfo.financialAccount)"
    }
    
    var httpHeaders: [String: String] {
        return DEFAULT_HEADERS
    }
}

/// This request creates a Check Deposit on Stripes backend, which will return a response for what other data is required to submit a deposit.
struct CreateCheckDepositRequest: NetworkRequest {
    
    var baseURL: URL {
        return URL(string: "https://api.stripe.com")!
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/v1/treasury/check_deposits"
    }
    
    var httpBody: Data? {
        return formEncodedHTTPBodyData(for: ["financial_account": K.APIInfo.financialAccount])
    }
    
    var httpHeaders: [String: String] {
        return loadHeaders(["Content-Type": "application/x-www-form-urlencoded"])
    }
}

/// A network request to upload a check image.
struct UploadImagesRequest: NetworkRequest {
    
    let checkImageName: String
    let checkImage: UIImage
    
    private let boundary = UUID().uuidString
    
    var baseURL: URL {
        return URL(string: "https://files.stripe.com")!
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/v1/files"
    }
    
    var httpBody: Data? {
        guard let imageData = checkImage.jpeg(.medium) else {
            assertionFailure("Failed to convert image to JPEG data.")
            return nil
        }
        
        guard let purposeData = "remote_deposit_capture_downloadable".data(using: .utf8) else {
            assertionFailure("Failed to convert string to UTF-8 data.")
            return nil
        }
        
        let imageFormData = NetworkFormData(key: "file", data: imageData, mimeType: "image/jpeg", filename: checkImageName + ".jpeg")
        let purposeFormData = NetworkFormData(key: "purpose", data: purposeData, mimeType: "text/plain", filename: nil)
        return multipartFormDataHTTPBody(boundary: boundary, for: [imageFormData, purposeFormData])
    }
    
    var httpHeaders: [String: String] {
        return loadHeaders(["Content-Type": "multipart/form-data; boundary=\(boundary)"])
    }
}

/// A POST request for updating a check with Image IDs from Stripe's file API. Requires a Check Details object that contains front and back check image IDs.
struct CheckDetailsUpdateRequest: NetworkRequest {
    let checkDespositID: String
    let checkDetails: CheckDetails
    
    var baseURL: URL {
        return URL(string: "https://api.stripe.com")!
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var path: String {
        // Example deposit ID: "rdcdi_1L6IWw2HgIlSv8poMuKOd1SG"
        return "/v1/treasury/check_deposits/\(checkDespositID)"
    }
    
    var httpBody: Data? {
        return formEncodedHTTPBodyData(for: [
            "check_details[description]": checkDetails.description,
            "check_details[amount]": String(checkDetails.amount),
            "check_details[currency]": "usd",
            "check_details[images][front]": checkDetails.images.front,
            "check_details[images][back]": checkDetails.images.back
        ])
    }
    
    var httpHeaders: [String: String] {
        return loadHeaders(["Content-Type": "application/x-www-form-urlencoded"])
    }
}

/// Request that sends just a Deposit ID to Stripe to confirm the details of a check depsoit.  
struct ConfirmDepositRequest: NetworkRequest {
    let depositID: String
    
    var baseURL: URL {
        return URL(string: "https://api.stripe.com")!
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/v1/treasury/check_deposits/\(depositID)/confirm"
    }
    
    var httpHeaders: [String: String] {
        return DEFAULT_HEADERS
    }
}
