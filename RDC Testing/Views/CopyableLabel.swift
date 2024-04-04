//
//  CopyableLabel.swift
//  RDC Testing
//
//  Created by Tim Isenman on 6/15/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

/// UILabel with class overrides that allow its contents to be copied into Pasteboard by a user if they long-press on the text.
final class CopyableLabel: UILabel {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu(sender:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return true
        }
        return false
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = text
    }
    
    @objc func showMenu(sender: AnyObject?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.showMenu(from: self, rect: bounds)
        }
    }
}
