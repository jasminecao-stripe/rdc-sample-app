//
//  NetworkRequestPerformer+AsyncAwait.swift
//  RDC Testing
//
//  Created by Tim Isenman on 6/8/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation
import Networking

extension NetworkRequestPerformer {
    /// `send()`request  type wraps around the NetworkRequestPerformer to allow Async/Await network calls
    public func send<ResponseType: Decodable>(_ request: NetworkRequest, requestBehaviors: [RequestBehavior] = [], decoder: JSONDecoder = JSONDecoder()) async throws -> ResponseType {
        return try await withCheckedThrowingContinuation { continuation in
            send(request, requestBehaviors: requestBehaviors, decoder: decoder) { (result: Result<ResponseType, NetworkError>) in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
