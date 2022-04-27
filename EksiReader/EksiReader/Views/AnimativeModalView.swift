//
//  AnimativeModalView.swift
//  EksiReader
//
//  Created by aybek can kaya on 25.04.2022.
//

import Foundation
import UIKit
import SwiftUI

struct AnimativeModalViewPosition {
    let frame: CGRect?
    let center: CGPoint?
    let size: CGSize?

    init(frame: CGRect) {
        self.frame = frame
        self.center = nil
        self.size = nil
    }

    init(center: CGPoint, size: CGSize) {
        self.center = center
        self.size = size
        self.frame = nil
    }
}

class AnimativeModalView: UIView {
    private var damping: CGFloat = 0.7
    private var response: CGFloat = 0.5
    private var xInitial: CGFloat = 0
    private var yInitial: CGFloat = 0

    private var initialPosition: AnimativeModalViewPosition = .init(frame: .zero)
    private var finalPosition: AnimativeModalViewPosition = .init(frame: .zero)

    private var contentViewTopConstraint: NSLayoutConstraint!
    private var contentViewLeadingConstraint: NSLayoutConstraint!
    private var contentViewWidthConstraint: NSLayoutConstraint!
    private var contentViewHeightConstraint: NSLayoutConstraint!


    private var viewContent = UIView
        .view()

    private var backgroundView = UIView
        .view()
        .backgroundColor(.black.withAlphaComponent(0.3))

    init() {
        super.init(frame: .zero)
        setUpUI()
        addListeners()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        backgroundView
            .add(into: self)
            .fit()

        viewContent
            .add(into: self)
            .roundCorners(by: 6)
            .backgroundColor(Styling.Application.backgroundColor)

        contentViewTopConstraint = viewContent.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        contentViewLeadingConstraint = viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
        contentViewWidthConstraint = viewContent.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0)
        contentViewHeightConstraint = viewContent.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0)

        contentViewTopConstraint.isActive = true
        contentViewLeadingConstraint.isActive = true
        contentViewWidthConstraint.isActive = true
        contentViewHeightConstraint.isActive = true

        viewContent.alpha = 0

    }

    private func addListeners() {
        addTapListeners()
        addPanGestureListeners()
    }

    private func addTapListeners() {
        backgroundView
            .onTap { _ in
                self.hide()
            }
    }

    private func addPanGestureListeners() {
        self.viewContent.onPan { recognizer in
            switch recognizer.state {
            case .began:
                break
            case .changed:
                let translation = recognizer.translation(in: self.superview!)
                recognizer.view!.center = CGPoint(x: translation.x + recognizer.view!.center.x,
                                                  y: translation.y + recognizer.view!.center.y)
                recognizer.setTranslation(.zero, in: self.superview)
               // self.handleViewState()
            case .ended:
                self.handlePanEnded()

               // self.handleViewState()
            default:
                break
            }
        }
    }

    private func handleViewState() {
        let initFrame = self.getFrame(from: self.initialPosition)
        let centerInitialPos = CGPoint(x: initFrame.origin.x + initFrame.size.width / 2 ,
                                       y: initFrame.origin.y + initFrame.size.height / 2)

        let finalFrame = self.getFrame(from: self.finalPosition)
        let centerFinalPos = CGPoint(x: finalFrame.origin.x + finalFrame.size.width / 2 ,
                                       y: finalFrame.origin.y + finalFrame.size.height / 2)
        let originalDistance = centerFinalPos.distance(from: centerInitialPos)
        let currentDistance = viewContent.center.distance(from: centerInitialPos)
        //NSLog("original : \(originalDistance), current: \(currentDistance)")
    }

    private func handlePanEnded() {
        let initFrame = self.getFrame(from: self.initialPosition)
        let centerInitialPos = CGPoint(x: initFrame.origin.x + initFrame.size.width / 2 ,
                                       y: initFrame.origin.y + initFrame.size.height / 2)

        let finalFrame = self.getFrame(from: self.finalPosition)
        let centerFinalPos = CGPoint(x: finalFrame.origin.x + finalFrame.size.width / 2 ,
                                       y: finalFrame.origin.y + finalFrame.size.height / 2)
        let originalDistance = centerFinalPos.distance(from: centerInitialPos)
        let currentDistance = viewContent.center.distance(from: centerInitialPos)

        let rate = currentDistance / originalDistance
        if rate < 0.5 {
            self.hide()
        } else {
            self.show()
        }
    }

    func setContentView(_ view: UIView) {
//        UIView
//            .view()
//            .add(into: viewContent)
//            .centerX(.constant(0))
//            .centerY(.constant(0))
//            .width(.constant(100))
//            .height(.constant(100))
//            .backgroundColor(.systemRed)

        //view.add(into: viewContent).fit()
    }

    func setInitialFrame(_ val: AnimativeModalViewPosition) {
        self.initialPosition = val
        self.setContentViewConstraints(position: self.initialPosition, isAnimated: false)
    }

    func setFinalFrame(_ val: AnimativeModalViewPosition) {
        self.finalPosition = val
    }

    private func setContentViewConstraints(position: AnimativeModalViewPosition, isAnimated: Bool) {
        let frame = getFrame(from: position)
        if isAnimated == false {
            contentViewTopConstraint.constant = frame.origin.y
            contentViewLeadingConstraint.constant = frame.origin.x
            contentViewHeightConstraint.constant = frame.size.height
            contentViewWidthConstraint.constant = frame.size.width
            self.layoutIfNeeded()
            return
        }

        if isAnimated {
            let style = DeclarativeAnimationStyle.spring(damping: damping,
                                                         response: response,
                                                         initialVelocity: .init(dx: xInitial, dy: yInitial))
            let animator = Anima
                .animate(with: style) {
                    self.contentViewTopConstraint.constant = frame.origin.y
                    self.contentViewLeadingConstraint.constant = frame.origin.x
                    self.contentViewHeightConstraint.constant = frame.size.height
                    self.contentViewWidthConstraint.constant = frame.size.width
                    self.layoutIfNeeded()
                }
            animator.start()
        }
    }

    func show() {
        if KeyWindow.subviews.compactMap({ $0 as? AnimativeModalView }).isEmpty {
            self.add(into: KeyWindow)
                .fit()
        }
        let frame = getFrame(from: finalPosition)
        self.alpha = 1.0
        self.viewContent.alpha = 1.0
        self.setContentViewConstraints(position: finalPosition, isAnimated: false)
    }

    func hide() {
        self.viewContent.subviews.forEach { $0.alpha = 0 }
        let style = DeclarativeAnimationStyle.spring(damping: damping,
                                                     response: response,
                                                     initialVelocity: .init(dx: xInitial, dy: yInitial))

        let animator = Anima
            .animate(with: style) {
                self.viewContent.frame = self.getFrame(from: self.initialPosition)
                self.backgroundView.alpha = 0
            }

        animator.onAnimationsCompleted {
            self.alpha = 0
            self.removeFromSuperview()
        }

        animator.start()
    }

    private func getFrame(from position: AnimativeModalViewPosition) -> CGRect {
        if let frame = position.frame { return frame }
        guard let center = position.center, let size = position.size else { return .zero }
        let xPos = center.x - size.width / 2
        let yPos = center.y - size.height / 2
        return .init(origin: .init(x: xPos, y: yPos), size: size)
    }

}

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}
