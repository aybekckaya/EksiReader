//
//  DeclarativeAnimations.swift
//  DeclarativeLayoutSample
//
//  Created by aybek can kaya on 22.02.2022.
//

import Foundation
import UIKit

let Anima = DeclarativeAnimation()

typealias DeclarativeAnimationCompletion = (() -> ())
typealias DeclarativeAnimationClosure = (() -> ())

enum DeclarativeAnimationStyle {
    case defaultAnimation(duration: TimeInterval,
                          options: UIView.AnimationOptions)

    case uiKitSpring(duration: TimeInterval,
                     options: UIView.AnimationOptions,
                     damping: CGFloat,
                     initialVelocity: CGFloat)

    case spring(damping: CGFloat,
                response: CGFloat,
                initialVelocity: CGVector = .zero)
}

enum DeclarativeAnimationType {
    case wait(duration: TimeInterval)
    case animation(style: DeclarativeAnimationStyle, animations: DeclarativeAnimationClosure)
}

class DeclarativeAnimation {

    private var _isAutoReverseEnabled: Bool = false // Implement
    private var type: DeclarativeAnimationStyle?

    private var animationIndex: Int = 0
    private var animationModels: [DeclarativeAnimationType] = []

    private var completion: DeclarativeAnimationCompletion?


    @discardableResult
    func wait(for interval: TimeInterval) -> DeclarativeAnimation {
        let type = DeclarativeAnimationType.wait(duration: interval)
        animationModels.append(type)
        return self
    }

    @discardableResult
    func onAnimationsCompleted(_ closure: @escaping DeclarativeAnimationCompletion) -> DeclarativeAnimation {
        self.completion = closure
        return self
    }

    @discardableResult
    func animate(with type: DeclarativeAnimationStyle, closure: @escaping DeclarativeAnimationClosure) -> DeclarativeAnimation {
        let type = DeclarativeAnimationType.animation(style: type, animations: closure)
        animationModels.append(type)
        return self
    }

    @discardableResult
    func start() -> DeclarativeAnimation {
        applyAnimationModel()
        return self
    }

    @discardableResult
    func clearQueuedAnimations() -> DeclarativeAnimation {
        animationModels = []
        return self 
    }
}

// MARK: - Animation Creator
extension DeclarativeAnimation {
    private func applyAnimationModel() {
        guard let currentModel = animationModels.first else {
            if let closure = self.completion {
                closure()
            }
            return
        }
        applyAnimationModel(with: currentModel)
        let _ = animationModels.removeFirst()
    }

    //    switch type {
    //    case .defaultAnimation(let duration, let animationOptions):
    //        startDefaultAnimation(duration: duration, options: animationOptions)
    //    case .uiKitSpring(let duration,
    //                      let animationOptions,
    //                      let damping,
    //                      let initialVelocity):
    //        //startUIKitSpringAnimation(damping: damping, initialVelocity: initialVelocity)
    //        break
    //    case .spring:
    //        break
    //    case .none:
    //        break
    //    }

    private func applyAnimationModel(with type: DeclarativeAnimationType) {
        switch type {
        case .wait(let duration):
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(duration * 1000))) {
                self.applyAnimationModel()
            }
        case .animation(let style, let animations):
            applyAnimation(with: style, animations: animations) {
                self.applyAnimationModel()
            }
        }
    }

    private func applyAnimation(with style: DeclarativeAnimationStyle, animations: @escaping DeclarativeAnimationClosure, completion: @escaping DeclarativeAnimationCompletion) {

        switch style {
        case .defaultAnimation(let duration, let options):
            startDefaultAnimation(duration: duration,
                                  options: options,
                                  animations: animations,
                                  completion: completion)
        case .uiKitSpring(let duration, let options, let damping, let initialVelocity):
            startUIKitSpringAnimation(duration: duration,
                                      options: options,
                                      damping: damping,
                                      initialVelocity: initialVelocity,
                                      animations: animations,
                                      completion: completion)
        case .spring(let damping, let response, let initialVelocity):
            startSpringAnimation(damping: damping,
                                 response: response,
                                 initialVelocity: initialVelocity,
                                 animations: animations,
                                 completion: completion)
        }

    }

    //    private func startUIKitSpringAnimation(damping: CGFloat, initialVelocity: CGFloat) {
    //        UIView.animate(withDuration: _duration, delay: _delay, usingSpringWithDamping: damping, initialSpringVelocity: initialVelocity, options: .layoutSubviews) {
    //            guard let animationsClosure = self.animationsClosure else { return }
    //            animationsClosure()
    //        } completion: { _ in
    //            guard let completion = self.completion else { return }
    //            completion()
    //        }
    //    }

    private func startDefaultAnimation(duration: TimeInterval,
                                       options: UIView.AnimationOptions,
                                       animations: @escaping DeclarativeAnimationClosure,
                                       completion: @escaping DeclarativeAnimationCompletion) {
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            animations()
        } completion: { _ in
            completion()
        }
    }

    private func startUIKitSpringAnimation(duration: TimeInterval,
                                           options: UIView.AnimationOptions,
                                           damping: CGFloat,
                                           initialVelocity: CGFloat,
                                           animations: @escaping DeclarativeAnimationClosure,
                                           completion: @escaping DeclarativeAnimationCompletion) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: initialVelocity,
                       options: options) {
            animations()
        } completion: { _ in
            completion()
        }
    }

    private func startSpringAnimation(damping: CGFloat,
                                      response: CGFloat,
                                      initialVelocity: CGVector,
                                      animations: @escaping DeclarativeAnimationClosure,
                                      completion: @escaping DeclarativeAnimationCompletion) {

        let springTimerContentView = UISpringTimingParameters(damping: damping,
                                                              response: response,
                                                              initialVelocity: initialVelocity)
        let animator = UIViewPropertyAnimator(duration: 0,
                                              timingParameters: springTimerContentView)

        animator.addCompletion { _ in
            completion()
        }

        animator.addAnimations {
            animations()
        }

        animator.startAnimation()
    }
}


fileprivate extension UISpringTimingParameters {

    /// A design-friendly way to create a spring timing curve.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}



//private func hideAlertContentView(with velocity: CGPoint) {
//    var newFrame = defaultContentViewFrame
//    newFrame.origin.x += velocity.x
//    newFrame.origin.y += velocity.y
//    let springTimerContentView = UISpringTimingParameters(damping: 0.5, response: 0.3)
//    let animatorContentView = UIViewPropertyAnimator(duration: 0, timingParameters: springTimerContentView)
//    animatorContentView.addAnimations {
//        self.alertContentView.frame = newFrame
//        self.alertContentView.alpha = 0
//        self.backgroundView.alpha = 0
//    }
//
//    animatorContentView.addCompletion { _ in
//        self.alertContentView.alpha = 0
//        self.backgroundView.alpha = 0
//        guard let delegate = self.delegate else { return }
//        delegate.podnaAlertAnimatorViewDidHide(self)
//    }
//    animatorContentView.startAnimation()
//}

