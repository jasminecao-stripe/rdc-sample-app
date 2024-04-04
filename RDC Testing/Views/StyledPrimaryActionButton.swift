//
//  StyledPrimaryActionButton.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/8/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

/// A button that is styled for primary actions, with the correct colors, fonts, and more.
final class StyledPrimaryActionButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? UIColor(named: "Stripe Blue") : .lightGray
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isHighlighted ? 0.3 : 1
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 5
        titleLabel?.font = .systemFont(ofSize: 16)
        setTitleColor(.white, for: .normal)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
