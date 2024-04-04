//
//  CheckDetailsModel.swift
//  RDC Testing
//
//  Created by Tim Isenman on 6/2/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import Foundation

/// Model for check specific details returned from Stripe in a check's detail update request
struct CheckDetails: Codable {
    let description: String
    let amount: Int
    let currency: String
    let images: CheckImagesModel
}

/// Sub-model of CheckDetails, containing the Stripe File API strings that correspond to a check deposit's check images
struct CheckImagesModel: Codable {
    let front: String
    let back: String
}

/// Part of the `UpdateCheckDetailsResponse`, describing the timeline for a check's deposit history.
struct StatusTransitions: Decodable {
    let canceledAt: Double?
    let confirmedAt: Double?
    let receivedAt: Double?
}

/// The response body from Stripe once a Check Deposit is given all necessary info for deposit confirmation. Returned when updating a deposit with image IDs, and after confirming a deposit to Stripe.
struct FullCheckDepositResponse: Decodable {
    let id: String
    let object: String
    let livemode: Bool
    let created: Double
    let financialAccount: String
    let status: DepositStatus
    let nextAction: NextAction?
    let statusTransitions: StatusTransitions
    let confirmableRiskFactors: [RiskFactors]?
    let checkDetails: CheckDetails?
}

/// The statuses that Stripe returns for a deposit given the check's details
enum DepositStatus: String, Decodable {
    case processing = "processing"
    case requiresAction = "requires_action"
    case requiresConfirmation = "requires_confirmation"
}

/// Information returned by Stripe after images IDs have been added to an active deposit. These tell a user what issues they need to resolve before their deposit can be submitted
struct RiskFactors: Decodable {
    let description: String
    let fields: [String]
    let reason: String
    let severity: String
}

/// Describes the type of next action a user must take to continue with their check deposit
struct NextAction: Decodable {
    let riskFactors: [RiskFactors]?
    let type: String
}
