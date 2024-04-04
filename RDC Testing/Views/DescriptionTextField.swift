//
//  CurrencyTextField.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/8/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

/// A `UITextField` that only allows number input and formats the field in USD currency.
final class DescriptionTextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = "Test check"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
