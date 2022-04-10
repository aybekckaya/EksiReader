//
//  UIEdgeInsets+Extensions.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 15.03.2022.
//

import Foundation
import UIKit

// MARK: - Edge insets
public extension UIEdgeInsets {
    static func fill(with value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    @discardableResult
     func top(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: self.left, bottom: self.bottom, right: self.right)
    }

    @discardableResult
     func left(_ value: CGFloat) -> UIEdgeInsets {
         return UIEdgeInsets(top: self.top, left: value, bottom: self.bottom, right: self.right)
    }

    @discardableResult
     func bottom(_ value: CGFloat) -> UIEdgeInsets {
         return UIEdgeInsets(top: self.top, left: self.left, bottom: value, right: self.right)
    }

    @discardableResult
     func right(_ value: CGFloat) -> UIEdgeInsets {
         return UIEdgeInsets(top: self.top, left: self.left, bottom: self.bottom, right: value)
    }
}
