//
//  DeclarativeLayout.swift
//  DeclarativeLayout
//
//  Created by Aybek Can Kaya on 24.07.2021.
//

import Foundation
import UIKit


// MARK: - DeclarativeLayoutValue
public enum DeclarativeLayoutValue {
    case min(_ value: CGFloat)
    case max(_ value: CGFloat)
    case constant(_ value: CGFloat)
}

// MARK: - DeclarativeLayoutIdentifier
public enum DeclarativeLayoutIdentifier: String {
    case top = "DeclarativeLayoutIdentifier-Top"
    case leading = "DeclarativeLayoutIdentifier-leading"
    case trailing = "DeclarativeLayoutIdentifier-trailing"
    case bottom = "DeclarativeLayoutIdentifier-bottom"
    case width = "DeclarativeLayoutIdentifier-width"
    case height = "DeclarativeLayoutIdentifier-height"
    case centerX = "DeclarativeLayoutIdentifier-centerX"
    case centerY = "DeclarativeLayoutIdentifier-centerY"
    case leftRelation = "DeclarativeLayoutIdentifier-leftRelation"
    case topRelation = "DeclarativeLayoutIdentifier-topRelation"
    case rightRelation = "DeclarativeLayoutIdentifier-rightRelation"
    case bottomRelation = "DeclarativeLayoutIdentifier-bottomRelation"
}

public enum DeclarativeLayoutRelation {
    case left(of: UIView, value: DeclarativeLayoutValue)
    case right(of: UIView, value: DeclarativeLayoutValue)
    case top(of: UIView, value: DeclarativeLayoutValue)
    case bottom(of: UIView, value: DeclarativeLayoutValue)
}

public enum DeclarativeLayoutRatioRelation {
    case width(of: UIView, value: CGFloat)
    case height(of: UIView, value: CGFloat)
}

// MARK: - Search
extension UIView {
    public func findConstraint(with identifier: DeclarativeLayoutIdentifier) -> NSLayoutConstraint? {
        return constraints.first { $0.identifier == identifier.rawValue}
    }
}

// MARK: - Constraints
extension UIView {
    private var parentView: UIView { self.superview! }

    @discardableResult
    public func fit(edges: UIEdgeInsets = .zero) -> UIView {
        return self
            .top(.constant(edges.top))
            .leading(.constant(edges.left))
            .trailing(.constant(edges.right))
            .bottom(.constant(edges.bottom))
    }

    @discardableResult
    public func alignToCenter(offset: CGPoint = .zero) -> UIView {
        return self
            .centerX(.constant(offset.x))
            .centerY(.constant(offset.y))
    }

    @discardableResult
    public func margin(to relation: DeclarativeLayoutRelation) -> UIView {
        switch relation {
        case .left(let of, let value):
            addLeftMargin(between: [self, of], value: value)
        case .right(let of, let value):
            addRightMargin(between: [self, of], value: value)
        case .top(let of, let value):
           addTopMargin(between: [self, of], value: value)
        case .bottom(let of, let value):
           addBottomMargin(between: [self, of], value: value)
        }
        return self
    }

    @discardableResult
    public func ratio(to relation: DeclarativeLayoutRatioRelation) -> UIView {
        switch relation {
        case .width(let of, let value):
            self.widthAnchor.constraint(equalTo: of.widthAnchor, multiplier: value).isActive = true
        case .height(let of, let value):
            self.heightAnchor.constraint(equalTo: of.heightAnchor, multiplier: value).isActive = true
        }
        return self
    }

    @discardableResult
    public func align(with relation: DeclarativeLayoutRelation) -> UIView {
        switch relation {
        case .left(let of, let value):
            addLeftAlignment(with: [self, of], value: value)
        case .right(let of, let value):
          addRightAlignment(with: [self, of], value: value)
        case .top(let of, let value):
            addTopAlignment(with: [self, of], value: value)
        case .bottom(let of, let value):
            addBottomMargin(between: [self, of], value: value)
        }
        return self
    }


    private func addLeftAlignment(with views: [UIView], value: DeclarativeLayoutValue) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
            constraint = views[0].leadingAnchor.constraint(greaterThanOrEqualTo: views[1].leadingAnchor, constant:  val)
        case .max(let val):
            constraint = views[0].leadingAnchor.constraint(lessThanOrEqualTo: views[1].leadingAnchor, constant:  val)
        case .constant(let val):
            constraint = views[0].leadingAnchor.constraint(equalTo: views[1].leadingAnchor, constant:  val)
        }

        constraint?.isActive = true
    }

    private func addRightAlignment(with views: [UIView], value: DeclarativeLayoutValue) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
            constraint = views[0].trailingAnchor.constraint(greaterThanOrEqualTo: views[1].trailingAnchor, constant:  val)
        case .max(let val):
            constraint = views[0].trailingAnchor.constraint(lessThanOrEqualTo: views[1].trailingAnchor, constant:  val)
        case .constant(let val):
            constraint = views[0].trailingAnchor.constraint(equalTo: views[1].trailingAnchor, constant:  val)
        }

        constraint?.isActive = true
    }

    private func addTopAlignment(with views: [UIView], value: DeclarativeLayoutValue) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
            constraint = views[0].topAnchor.constraint(greaterThanOrEqualTo: views[1].topAnchor, constant:  val)
        case .max(let val):
            constraint = views[0].topAnchor.constraint(lessThanOrEqualTo: views[1].topAnchor, constant:  val)
        case .constant(let val):
            constraint = views[0].topAnchor.constraint(equalTo: views[1].topAnchor, constant:  val)
        }

        constraint?.isActive = true
    }

    private func addBottomAlignment(with views: [UIView], value: DeclarativeLayoutValue) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
            constraint = views[0].bottomAnchor.constraint(greaterThanOrEqualTo: views[1].bottomAnchor, constant:  val)
        case .max(let val):
            constraint = views[0].bottomAnchor.constraint(lessThanOrEqualTo: views[1].bottomAnchor, constant:  val)
        case .constant(let val):
            constraint = views[0].bottomAnchor.constraint(equalTo: views[1].bottomAnchor, constant:  val)
        }

        constraint?.isActive = true
    }

//    private func addBottomMargin(between views: [UIView], value: DeclarativeLayoutValue) {
//        self.translatesAutoresizingMaskIntoConstraints = false
//        var constraint: NSLayoutConstraint?
//
//        switch value {
//        case .min(let val):
//            constraint = views[0].topAnchor.constraint(greaterThanOrEqualTo: views[1].bottomAnchor, constant:  val)
//        case .max(let val):
//           constraint = views[0].topAnchor.constraint(lessThanOrEqualTo: views[1].bottomAnchor, constant:  val)
//        case .constant(let val):
//           constraint = views[0].topAnchor.constraint(equalTo: views[1].bottomAnchor, constant:  val)
//        }
//
//        constraint?.isActive = true
//        constraint?.identifier = DeclarativeLayoutIdentifier.topRelation.rawValue
//    }


    @discardableResult
    public func top(_ value: DeclarativeLayoutValue) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
           constraint = self.topAnchor.constraint(greaterThanOrEqualTo: parentView.topAnchor, constant: val)
        case .max(let val):
           constraint = self.topAnchor.constraint(lessThanOrEqualTo: parentView.topAnchor, constant: val)
        case .constant(let val):
           constraint = self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: val)
        }
        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.top.rawValue
        return self
    }

    @discardableResult
    public func leading(_ value: DeclarativeLayoutValue) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
          constraint = self.leadingAnchor.constraint(greaterThanOrEqualTo: parentView.leadingAnchor, constant: val)
        case .max(let val):
           constraint = self.leadingAnchor.constraint(lessThanOrEqualTo: parentView.leadingAnchor, constant: val)
        case .constant(let val):
         constraint = self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: val)
        }
        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.leading.rawValue
        return self
    }

    @discardableResult
    public func trailing(_ value: DeclarativeLayoutValue) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
            constraint = self.trailingAnchor.constraint(lessThanOrEqualTo: parentView.trailingAnchor, constant: -1 * val)
        case .max(let val):
            constraint =  self.trailingAnchor.constraint(greaterThanOrEqualTo: parentView.trailingAnchor, constant: -1 * val)
        case .constant(let val):
            constraint = self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -1 * val)
        }
        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.trailing.rawValue
        return self
    }

    @discardableResult
    public func bottom(_ value: DeclarativeLayoutValue) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
         constraint = self.bottomAnchor.constraint(lessThanOrEqualTo: parentView.bottomAnchor, constant: -1 * val)
        case .max(let val):
          constraint = self.bottomAnchor.constraint(greaterThanOrEqualTo: parentView.bottomAnchor, constant: -1 * val)
        case .constant(let val):
           constraint = self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -1 * val)
        }
        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.bottom.rawValue
        return self
    }

    @discardableResult
    public func centerX(_ value: DeclarativeLayoutValue) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
         constraint =   self.centerXAnchor.constraint(lessThanOrEqualTo: parentView.centerXAnchor, constant: val)
        case .max(let val):
          constraint =  self.centerXAnchor.constraint(greaterThanOrEqualTo: parentView.centerXAnchor, constant: val)
        case .constant(let val):
          constraint =  self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: val)
        }
        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.centerX.rawValue
        return self
    }

    @discardableResult
    public func centerY(_ value: DeclarativeLayoutValue) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
            constraint = self.centerYAnchor.constraint(lessThanOrEqualTo: parentView.centerYAnchor, constant: val)
        case .max(let val):
          constraint = self.centerYAnchor.constraint(greaterThanOrEqualTo: parentView.centerYAnchor, constant: val)
        case .constant(let val):
          constraint =  self.centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: val)
        }
        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.centerY.rawValue
        return self
    }

    @discardableResult
    public func width(_ value: DeclarativeLayoutValue) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
            constraint = self.widthAnchor.constraint(greaterThanOrEqualToConstant: val)
        case .max(let val):
            constraint = self.widthAnchor.constraint(lessThanOrEqualToConstant: val)
        case .constant(let val):
            constraint = self.widthAnchor.constraint(equalToConstant: val)
        }
        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.width.rawValue
        return self
    }

    @discardableResult
    public func height(_ value: DeclarativeLayoutValue) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?
        switch value {
        case .min(let val):
            constraint =  self.heightAnchor.constraint(greaterThanOrEqualToConstant: val)
        case .max(let val):
            constraint = self.heightAnchor.constraint(lessThanOrEqualToConstant: val)
        case .constant(let val):
            constraint =  self.heightAnchor.constraint(equalToConstant: val)
        }
        constraint?.identifier = DeclarativeLayoutIdentifier.height.rawValue
        constraint?.isActive = true

        return self
    }


    @discardableResult
    public func aspectRatio(_ value: CGFloat) -> UIView {
        self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: value).isActive = true
        return self
    }
}

// MARK: - Margin Helper
extension UIView {
    private func addBottomMargin(between views: [UIView], value: DeclarativeLayoutValue) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?

        switch value {
        case .min(let val):
            constraint = views[0].topAnchor.constraint(greaterThanOrEqualTo: views[1].bottomAnchor, constant:  val)
        case .max(let val):
           constraint = views[0].topAnchor.constraint(lessThanOrEqualTo: views[1].bottomAnchor, constant:  val)
        case .constant(let val):
           constraint = views[0].topAnchor.constraint(equalTo: views[1].bottomAnchor, constant:  val)
        }

        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.topRelation.rawValue
    }

    private func addTopMargin(between views: [UIView], value: DeclarativeLayoutValue) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?

        switch value {
        case .min(let val):
            constraint = views[0].bottomAnchor.constraint(greaterThanOrEqualTo: views[1].topAnchor, constant: -1 * val)
        case .max(let val):
           constraint = views[0].bottomAnchor.constraint(lessThanOrEqualTo: views[1].topAnchor, constant: -1 * val)
        case .constant(let val):
           constraint = views[0].bottomAnchor.constraint(equalTo: views[1].topAnchor, constant: -1 * val)
        }

        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.topRelation.rawValue
    }

    private func addRightMargin(between views: [UIView], value: DeclarativeLayoutValue) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?

        switch value {
        case .min(let val):
            constraint = views[0].leadingAnchor.constraint(greaterThanOrEqualTo: views[1].trailingAnchor, constant: val)
        case .max(let val):
           constraint = views[0].leadingAnchor.constraint(lessThanOrEqualTo: views[1].trailingAnchor, constant: val)
        case .constant(let val):
           constraint = views[0].leadingAnchor.constraint(equalTo: views[1].trailingAnchor, constant: val)
        }

        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.rightRelation.rawValue
    }

    private func addLeftMargin(between views: [UIView], value: DeclarativeLayoutValue) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint?

        switch value {
        case .min(let val):
            constraint = views[0].trailingAnchor.constraint(greaterThanOrEqualTo: views[1].leadingAnchor, constant: val * -1)
        case .max(let val):
           constraint = views[0].trailingAnchor.constraint(lessThanOrEqualTo: views[1].leadingAnchor, constant: val * -1)
        case .constant(let val):
           constraint = views[0].trailingAnchor.constraint(equalTo: views[1].leadingAnchor, constant: val * -1)
        }

        constraint?.isActive = true
        constraint?.identifier = DeclarativeLayoutIdentifier.leftRelation.rawValue
    }

}
