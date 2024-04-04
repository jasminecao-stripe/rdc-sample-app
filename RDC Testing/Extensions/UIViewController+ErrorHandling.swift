//
//  UIViewController+ErrorHandling.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/9/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit
import Networking

extension UIViewController {
    
    /// Shows an alert for the given error, with special handling for some NetworkError types.
    /// - Parameter error: The error to show.
    func showErrorAlert(for error: Error) {
        let title: String?
        let message: String?
        let action: UIAlertAction?
        
        switch error {
        case let error as NetworkError:
            title = error.errorDescription
            
            switch error {
            case let .unsuccessfulStatusCode(_, data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let additionalMessageString: String
                if let data = data {
                    if let stripeAPIErrorResponse = try? decoder.decode(StripeAPIErrorResponse.self, from: data) {
                        additionalMessageString = String.localizedStringWithFormat(NSLocalizedString("Stripe API Error:\n%@\n\nError Type: %@", comment: "Additional text showing a Stripe API error response to display to the user."), stripeAPIErrorResponse.error.message, stripeAPIErrorResponse.error.type)
                    } else if let responseString = String(data: data, encoding: .utf8) {
                        additionalMessageString = String.localizedStringWithFormat(NSLocalizedString("API Error:\n%@", comment: "Additional text showing an API error response to display to the user."), responseString)
                    } else {
                        additionalMessageString = ""
                    }
                } else {
                    additionalMessageString = ""
                }

                message = error.failureReason.map { $0 + "\n\n" + additionalMessageString } ?? additionalMessageString
                
                action = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy button on alert"), style: .default) { _ in
                    UIPasteboard.general.string = additionalMessageString
                }
            case .decodingError(let decodingError):
                message = (error.failureReason ?? "") + "\n\n" + decodingError.localizedDescription
                action = nil
            case .noData, .noResponse, .underlyingNetworkingError:
                message = error.failureReason
                action = nil
            }
        default:
            title = NSLocalizedString("Uknown Error", comment: "The title for an alert when an uknown error occurs")
            message = error.localizedDescription
            action = nil
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let action = action {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Cancel button on alert"), style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
}
