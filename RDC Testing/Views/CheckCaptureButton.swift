//
//  CheckCaptureButton.swift
//  RDC Testing
//
//  Created by Brian Capps on 6/7/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

/// A button that is styled for capturing a check, showing an empty and a captured state.
final class CheckCaptureButton: UIButton {
    
    enum ViewModel {
        case empty
        case checkImage(UIImage)
        
        init(image: UIImage?) {
            if let image = image {
                self = .checkImage(image)
            } else {
                self = .empty
            }
        }
    }
    
    private let checkImageView = UIImageView()
    private let dimmedOverlay = UIView()
    private let iconView = UIImageView()
    
    private var dashedLineBorderLayer: CAShapeLayer?
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isHighlighted ? 0.3 : 1
            }
        }
    }

    var viewModel: ViewModel = .empty {
        didSet {
            updateView()
        }
    }
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 4
        layer.masksToBounds = true

        addSubview(checkImageView)
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.pinEdges(to: self)
        checkImageView.contentMode = .scaleToFill
        
        addSubview(dimmedOverlay)
        dimmedOverlay.translatesAutoresizingMaskIntoConstraints = false
        dimmedOverlay.pinEdges(to: self)
        
        dimmedOverlay.isUserInteractionEnabled = false
        dimmedOverlay.backgroundColor = UIColor(named: "Stripe Blue")?.withAlphaComponent(0.4)
        
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .center
        iconView.pinEdges(to: self)
                
        addTarget(self, action: #selector(didSelectButton), for: .primaryActionTriggered)
        
        let dashedLineBorderLayer = CAShapeLayer()
        dashedLineBorderLayer.strokeColor = UIColor.darkGray.cgColor
        dashedLineBorderLayer.fillColor = nil
        layer.addSublayer(dashedLineBorderLayer)
        self.dashedLineBorderLayer = dashedLineBorderLayer
        
        updateView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateBorder()
    }
    
    private func updateBorder() {
        dashedLineBorderLayer?.lineDashPattern = viewModel.lineDashPattern
        dashedLineBorderLayer?.frame = layer.bounds
        dashedLineBorderLayer?.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 4, height: 4)).cgPath
    }

    private func updateView() {
        switch viewModel {
        case .empty:
            checkImageView.image = nil
            dimmedOverlay.alpha = 0
            iconView.image = UIImage(named: "Camera Icon")
        case .checkImage(let image):
            checkImageView.image = image
            dimmedOverlay.alpha = 1
            iconView.image = UIImage(named: "Checkmark Icon")
        }
        
        updateBorder()
    }
    
    @objc private func didSelectButton() {
        onTap?()
    }
}

private extension CheckCaptureButton.ViewModel {
    var lineDashPattern: [NSNumber]? {
        switch self {
        case .empty:
            return [2, 2]
        case .checkImage:
            return nil
        }
    }
}
