//
//  DepositStatusHeader.swift
//  RDC Testing
//
//  Created by Tim Isenman on 6/9/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

/// A header view that shows the deposit status with a large image and title.
final class DepositStatusHeader: UIView {
    var statusImage: UIImage? {
        didSet {
            statusImageView.image = statusImage
        }
    }
    
    var statusTitle: String? {
        didSet {
            statusTitleLabel.text = statusTitle
        }
    }
    
    private let stackView = UIStackView()
    private var statusImageView = UIImageView()
    private var statusTitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.pinEdges(to: self)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        
        stackView.addArrangedSubview(statusImageView)
        statusImageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            statusImageView.widthAnchor.constraint(equalToConstant: 130),
            statusImageView.heightAnchor.constraint(equalToConstant: 130)
        ])
        statusImageView.sizeToFit()
        
        stackView.addArrangedSubview(statusTitleLabel)
        statusTitleLabel.font = .preferredFont(forTextStyle: .title1)
        statusTitleLabel.textColor = .label
        NSLayoutConstraint.activate([
            statusTitleLabel.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
