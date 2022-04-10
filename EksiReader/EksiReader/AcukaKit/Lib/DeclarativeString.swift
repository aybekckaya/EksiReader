//
//  DeclarativeString.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 14.03.2022.
//

import Foundation
import UIKit

//let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
//let underlineAttributedString = NSAttributedString(string: "StringWithUnderLine", attributes: underlineAttribute)
//myLabel.attributedText = underlineAttributedString

extension String {
    var attributedString: NSAttributedString {
        NSAttributedString(string: self)
    }

//    func rangeOf(text: String) -> NSRange {
//        NSRange(location: <#T##Int#>, length: <#T##Int#>)
//        return self.index(of: text)
//    }
}

extension NSAttributedString {
    @discardableResult
    static func combine(_ arr: [NSAttributedString]) -> NSAttributedString {
        let combination = NSMutableAttributedString()
        arr.forEach { combination.append($0) }
        return combination
    }

    @discardableResult
    func font(_ font: UIFont) -> NSAttributedString {
        let attribute = [NSAttributedString.Key.font: font]
        return applyAttribute(attribute)
    }

    @discardableResult
    func underline(style: NSUnderlineStyle = NSUnderlineStyle.thick,
                   color: UIColor) -> NSAttributedString {

        let underlineAttribute: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.underlineStyle: style.rawValue,
            NSAttributedString.Key.underlineColor: color
        ]
        return applyAttribute(underlineAttribute)
    }

    private func applyAttribute(_ attribute: [NSAttributedString.Key : Any]) -> NSAttributedString {
        let attributedMutableString = NSMutableAttributedString(attributedString: self)
        attributedMutableString.addAttributes(attribute,
                                              range: NSRange(location: 0, length: self.length))
        return attributedMutableString
    }
}

//extension StringProtocol {
//    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
//        range(of: string, options: options)?.lowerBound
//    }
//    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
//        range(of: string, options: options)?.upperBound
//    }
//    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
//        ranges(of: string, options: options).map(\.lowerBound)
//    }
//    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
//        var result: [Range<Index>] = []
//        var startIndex = self.startIndex
//        while startIndex < endIndex,
//            let range = self[startIndex...]
//                .range(of: string, options: options) {
//                result.append(range)
//                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
//                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
//        }
//        return result
//    }
//}
