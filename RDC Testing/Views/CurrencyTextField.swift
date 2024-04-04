//
//  CurrencyTextField.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/8/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

/// A `UITextField` that only allows number input and formats the field in USD currency.
final class CurrencyTextField: UITextField {
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    var decimal: Decimal? {
        guard let text = text else {
            return nil
        }
        
        return text.decimal / pow(10, Self.currencyFormatter.maximumFractionDigits)
    }
    
    var cents: Int? {
        guard let decimalDouble = (decimal as? NSDecimalNumber)?.doubleValue else {
            return nil
        }

        return Int(decimalDouble * pow(10, Double(Self.currencyFormatter.maximumFractionDigits)))
    }
    
    private var maximum: Decimal = 999_999_999.99
    private var lastValue: String?
    
    private let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyboardType = .numberPad
        placeholder = "$0.00"
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        text = text.map { String($0.digits.dropLast()) }
        sendActions(for: .editingChanged)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    @objc private func editingChanged() {
        guard let decimal = decimal, decimal <= maximum else {
            text = lastValue
            return
        }
        
        text = Self.currencyFormatter.string(for: decimal)
        lastValue = text
    }
}

private extension StringProtocol where Self: RangeReplaceableCollection {
    var digits: Self {
        return filter(\.isWholeNumber)
    }
}

private extension String {
    var decimal: Decimal {
        return Decimal(string: digits) ?? 0
    }
}
