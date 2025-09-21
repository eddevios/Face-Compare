//
//  UIView+Extensions.swift
//  FaceCompare
//
//  Created by Edu on 20/9/25.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func roundCorners(radius: CGFloat = AppConstants.Design.CornerRadius.medium) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func addBorder(color: UIColor = AppConstants.Colors.primary, width: CGFloat = 1.0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}
