//
//  CGRect+Extensions.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 15.03.2022.
//

import Foundation
import UIKit

public extension CGRect {
    @discardableResult
    static func fill(_ value: CGFloat) -> CGRect {
        return CGRect(x: value, y: value, width: value, height: value)
    }

    @discardableResult
    func x(_ value: CGFloat) -> CGRect {
        return .init(x: value, y: self.origin.y, width: self.size.width, height: self.size.height)
    }

    @discardableResult
    func y(_ value: CGFloat) -> CGRect {
        return .init(x: self.origin.x, y: value, width: self.size.width, height: self.size.height)
    }

    @discardableResult
    func width(_ value: CGFloat) -> CGRect {
        return .init(x: self.origin.x, y: self.origin.y, width: value, height: self.size.height)
    }

    @discardableResult
    func height(_ value: CGFloat) -> CGRect {
        return .init(x: self.origin.x, y: self.origin.y, width: self.size.width, height: value)
    }
}
