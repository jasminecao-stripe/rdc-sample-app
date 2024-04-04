//
//  NetworkRequest+FormEncoding.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/1/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation
import Networking

extension NetworkRequest {
    /// Returns form-encoded data for use in an HTTP body on a POST or PUT request. Based loosely on this answer from an Apple engineer:  https://developer.apple.com/forums/thread/113632?answerId=349535022#349535022
    /// - Parameter items: The keys and values to form-encode.
    /// - Returns: Form-encoded data for use in an HTTP body on a POST or PUT request.
    func formEncodedHTTPBodyData(for items: [String: String]) -> Data? {
        let formEncodedString = items.map { key, value in
            return "\(key.formEncodingEscaped())=\(value.formEncodingEscaped())"
        }.joined(separator: "&")
        
        return formEncodedString.data(using: .utf8)
    }
}

private extension String {
    private var formEncodingAllowedCharacters: CharacterSet {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.insert(" ") // Allow this character to later replace it with `+`
        allowed.remove("+")
        allowed.remove("/")
        allowed.remove("?")
        return allowed
    }

    func formEncodingEscaped() -> String {
        let escapedString = replacingOccurrences(of: "\n", with: "\r\n")
            .addingPercentEncoding(withAllowedCharacters: formEncodingAllowedCharacters)?
            .replacingOccurrences(of: " ", with: "+")
        guard let escapedString = escapedString else {
            assertionFailure("String that was escaped could not be percent encoded, likely because it is not UTF-8.")
            return self
        }
        
        return escapedString
    }
}
