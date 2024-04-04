//
//  LayoutGuide.swift
//  RDC Testing
//
//  Created by Brian Capps on 5/17/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit

/// Provides a single API for the layout guides that are shared between `UIView` and `UILayoutGuide`.
protocol LayoutGuide {
    
    /// A layout anchor representing the leading edge.
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    
    /// A layout anchor representing the trailing edge.
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    
    /// A layout anchor representing the left edge.
    var leftAnchor: NSLayoutXAxisAnchor { get }
    
    /// A layout anchor representing the right edge.
    var rightAnchor: NSLayoutXAxisAnchor { get }
    
    /// A layout anchor representing the top edge.
    var topAnchor: NSLayoutYAxisAnchor { get }
    
    /// A layout anchor representing the bottom edge.
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    
    /// A layout anchor representing the width.
    var widthAnchor: NSLayoutDimension { get }
    
    /// A layout anchor representing the height.
    var heightAnchor: NSLayoutDimension { get }
    
    /// A layout anchor representing the horizontal center.
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    
    /// A layout anchor representing the vertical center.
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

/// Extends `UIView` to conform to `LayoutGuide`.
extension UIView: LayoutGuide {}

/// Extends `UILayoutGuide` to conform to `LayoutGuide`.
extension UILayoutGuide: LayoutGuide {}

/// Extends `LayoutGuide` to provide a convenience method for pinning to edges.
extension LayoutGuide {
    
    /// Pins the receiver to the specified layout guide’s edges, activating the relevant constraints.
    ///
    /// - Parameters:
    ///   - edges: The edges used to pin the receiver to the specified layout guide.
    ///   - layoutGuide: The layout guide to pin the receiver to.
    ///   - insets: Insets to use relative to the specified edges.
    /// - Returns: The constraints that were activated.
    @discardableResult func pinEdges(_ edges: NSDirectionalRectEdge = .all, to layoutGuide: LayoutGuide, insets: NSDirectionalEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let topConstraint = edges.contains(.top) ? topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top) : nil
        let leadingConstraint = edges.contains(.leading) ? leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.leading) : nil
        let trailingConstraint = edges.contains(.trailing) ? trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -insets.trailing) : nil
        let bottomConstraint = edges.contains(.bottom) ? bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -insets.bottom) : nil
        let constraints = [topConstraint, leadingConstraint, trailingConstraint, bottomConstraint].compactMap { return $0 }
        
        NSLayoutConstraint.activate(constraints)
        
        return constraints
    }
}
