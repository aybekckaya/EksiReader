//
//  UIBarButton+Frame.swift
//  EksiReader
//
//  Created by aybek can kaya on 25.04.2022.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    var view: UIView? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view
    }

    var frame: CGRect? {
        guard let view = self.view, let superView = view.superview else {
            return nil
        }
        let xPos = superView.frame.origin.x
        let yPos = view.frame.origin.y
        let width = view.frame.size.width
        let height = view.frame.size.height
        return .init(x: xPos, y: yPos, width: width, height: height)
    }

    var center: CGPoint? {
        guard let frame = frame else {
            return nil
        }
        return .init(x: frame.origin.x + frame.size.width / 2,
                     y: frame.origin.y + frame.size.height / 2)
    }

}
