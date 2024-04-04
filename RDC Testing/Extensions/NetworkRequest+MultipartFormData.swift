//
//  NetworkRequest+MultipartFormData.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/2/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation
import Networking

/// An individual item in a multipart/form-data request.
struct NetworkFormData {
    /// The key associated with this item. For example, if you see `key=value` in sample documentation, this represents the left side of that assignment.
    let key: String
    
    /// The actual data to encode as the value.
    let data: Data
    
    /// The MIME type of the data.
    let mimeType: String
    
    /// The name of the file being uploaded. Optional.
    let filename: String?
}

extension NetworkRequest {
    
    /// Returns HTTP body data formatted for a multipart/form-data request.
    /// - Parameters:
    ///   - boundary: The boundary to use between items and at the end of the body.
    ///   - items: The items to list in the body.
    /// - Returns: HTTP body data formatted for a multipart/form-data request.
    func multipartFormDataHTTPBody(boundary: String, for items: [NetworkFormData]) -> Data? {
        var data = Data()
        
        for item in items {
            let filenameString = item.filename.map { "; filename=\"\($0)\"" } ?? ""
            
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(item.key)\"\(filenameString)\r\n")
            data.append("Content-Type: \(item.mimeType)\r\n")
            data.append("\r\n")
            data.append(item.data)
            data.append("\r\n")
        }
        
        data.append("--\(boundary)--")
        return data
    }
}

private extension Data {
    mutating func append(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            assertionFailure("String could not be converted to UTF-8 data.")
            return
        }
        
        append(data)
    }
}
