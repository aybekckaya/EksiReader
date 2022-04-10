//
//  UIViewGestureExtension.swift
//  DeclarativeLayoutSample
//
//  Created by aybek can kaya on 21.02.2022.
//

import Foundation
import UIKit

typealias TapAction = ((UITapGestureRecognizer) -> Void)?
typealias PanAction = ((UIPanGestureRecognizer) -> Void)?
typealias TouchAction = ((TouchState) -> Void)?

enum TouchState {
    case began(UITouch, UIView)
    case moved(UITouch, UIView)
    case ended(UITouch, UIView)
}

//class TouchGesture {
//    private var touchBegan: (()->())?
//
//    func began(_ closure: @escaping ()->()) {
//        self.touchBegan = closure
//    }
//}


// MARK: - Tap Gesture
extension UIView {

    fileprivate var tapGestureRecognizerAction: TapAction? {
        set {
            setAssociatedObject(key: &AssociatedObjectKeys.tapGestureRecognizer, value: newValue as Any?)
        }
        get {
            return getAssociatedObject(key: &AssociatedObjectKeys.tapGestureRecognizer) as? TapAction
        }
    }

    @discardableResult
    func onTap(action: TapAction) -> UIView {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
        return self
    }

    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        guard let tapGestureRecognizerAction = tapGestureRecognizerAction else {
            return
        }
        tapGestureRecognizerAction?(sender)
    }

    //    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        NSLog("Touch Start")
    //    }
}

// MARK: - Pan Gesture
extension UIView {
    fileprivate var panGestureRecognizerAction: PanAction? {
        set {
            setAssociatedObject(key: &AssociatedObjectKeys.panGestureRecognizer, value: newValue as Any?)
        }
        get {
            return getAssociatedObject(key: &AssociatedObjectKeys.panGestureRecognizer) as? PanAction
        }
    }

    @discardableResult
    func onPan(_ closure: PanAction) -> UIView {
        self.isUserInteractionEnabled = true
        self.panGestureRecognizerAction = closure
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:)))
        self.addGestureRecognizer(panGesture)
        return self
    }

    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        guard let panGestureRecognizerAction = panGestureRecognizerAction else {
            return
        }
        panGestureRecognizerAction?(sender)
    }
}

// MARK: - Touch Events
extension UIView {
    fileprivate var touchAction: TouchAction? {
        set {
            setAssociatedObject(key: &AssociatedObjectKeys.touchRecognizer, value: newValue as Any?)
        }
        get {
            return getAssociatedObject(key: &AssociatedObjectKeys.touchRecognizer) as? TouchAction
        }
    }

    @discardableResult
    func onTouch(_ closure: TouchAction) -> UIView {
        self.touchAction = closure
        return self
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let touchAction = touchAction else {
            return
        }
        let state = TouchState.began(touch, self)
        touchAction?(state)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let touchAction = touchAction else {
            return
        }
        let state = TouchState.moved(touch, self)
        touchAction?(state)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let touchAction = touchAction else {
            return
        }
        let state = TouchState.ended(touch, self)
        touchAction?(state)
    }
}

//// MARK: - UITouch
//typealias TouchStateAction = ((UIView, UITouch) -> Void)?
//extension UITouch {
//    fileprivate struct AssociatedObjectKeys {
//        static var beganKey = "UITouch-began"
//        static var movedKey = "UITouch-moved"
//        static var endedKey = "UITouch-ended"
//    }
//
//    fileprivate func getAssociatedObject(key: UnsafeRawPointer) -> Any? {
//        return objc_getAssociatedObject(self, key)
//    }
//
//    fileprivate func setAssociatedObject(key: UnsafeRawPointer, value: Any?) {
//        guard let value = value else {
//            return
//        }
//
//        objc_setAssociatedObject(self,
//                                 key,
//                                 value,
//                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//    }
//
//    fileprivate var beganAction: TouchStateAction? {
//        set {
//            setAssociatedObject(key: &AssociatedObjectKeys.beganKey, value: newValue as Any?)
//        }
//        get {
//            return getAssociatedObject(key: &AssociatedObjectKeys.beganKey) as? TouchStateAction
//        }
//    }
//
//    fileprivate var movedAction: TouchStateAction? {
//        set {
//            setAssociatedObject(key: &AssociatedObjectKeys.movedKey, value: newValue as Any?)
//        }
//        get {
//            return getAssociatedObject(key: &AssociatedObjectKeys.movedKey) as? TouchStateAction
//        }
//    }
//
//    fileprivate var endedAction: TouchStateAction? {
//        set {
//            setAssociatedObject(key: &AssociatedObjectKeys.endedKey, value: newValue as Any?)
//        }
//        get {
//            return getAssociatedObject(key: &AssociatedObjectKeys.endedKey) as? TouchStateAction
//        }
//    }
//
//
//}



// MARK: - Associated Objects
extension UIView {
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "UIView-tapGestureRecognizer"
        static var panGestureRecognizer = "UIView-panGestureRecognizer"
        static var touchRecognizer = "UIView-touchRecognizer"
    }

    fileprivate func getAssociatedObject(key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }

    fileprivate func setAssociatedObject(key: UnsafeRawPointer, value: Any?) {
        guard let value = value else {
            return
        }

        objc_setAssociatedObject(self,
                                 key,
                                 value,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

// MARK: - UITextfield
typealias UITextfieldDidBeginEditingAction = ((UITextField)->())?
typealias UITextfieldDidEndEditingAction = ((UITextField)->())?
typealias UITextfieldDidChangeEditingAction = ((UITextField)->())?

extension UITextField {
    fileprivate struct AssociatedObjectKeys {
        static var beginEditing = "UITextfield-begin-editing"
        static var endEditing = "UITextfield-end-editing"
        static var changeText = "UITextfield-chenge-editing"
    }

    fileprivate var textfieldBeginEditingAction: UITextfieldDidBeginEditingAction? {
        set {
            setAssociatedObject(key: &AssociatedObjectKeys.beginEditing, value: newValue as Any?)
        }
        get {
            return getAssociatedObject(key: &AssociatedObjectKeys.beginEditing) as? UITextfieldDidBeginEditingAction
        }
    }

    fileprivate var textfieldEndEditingAction: UITextfieldDidEndEditingAction? {
        set {
            setAssociatedObject(key: &AssociatedObjectKeys.endEditing, value: newValue as Any?)
        }
        get {
            return getAssociatedObject(key: &AssociatedObjectKeys.endEditing) as? UITextfieldDidEndEditingAction
        }
    }

    fileprivate var textfieldChangeEditingAction: UITextfieldDidChangeEditingAction? {
        set {
            setAssociatedObject(key: &AssociatedObjectKeys.changeText, value: newValue as Any?)
        }
        get {
            return getAssociatedObject(key: &AssociatedObjectKeys.changeText) as? UITextfieldDidChangeEditingAction
        }
    }

    @discardableResult
    func onBeginEditing(_ closure: UITextfieldDidBeginEditingAction) -> UITextField {
        self.textfieldBeginEditingAction = closure
        self.addTarget(self, action: #selector(didBeginEditingOnCall), for: .editingDidBegin)
        return self
    }

    @discardableResult
    func onEndEditing(_ closure: UITextfieldDidEndEditingAction) -> UITextField {
        self.textfieldEndEditingAction = closure
        self.addTarget(self, action: #selector(didEndEditingOnCall), for: .editingDidEnd)
        return self
    }

    @discardableResult
    func onTextChanged(_ closure: UITextfieldDidChangeEditingAction) -> UITextField {
        self.textfieldChangeEditingAction = closure
        self.addTarget(self, action: #selector(didChangeEditingOnCall), for: .editingChanged)
        return self
    }

    @objc private func didBeginEditingOnCall() {
        guard let textfieldBeginEditingAction = self.textfieldBeginEditingAction else { return }
        textfieldBeginEditingAction?(self)
    }

    @objc private func didEndEditingOnCall() {
        guard let textfieldEndEditingAction = self.textfieldEndEditingAction else { return }
        textfieldEndEditingAction?(self)
    }

    @objc private func didChangeEditingOnCall() {
        guard let textfieldChangeEditingAction = self.textfieldChangeEditingAction else {
            return
        }
        textfieldChangeEditingAction?(self)
    }

}


// MARK: - UIButton
typealias UIButtonTapAction = ((UIButton)->())?

extension UIButton {
    fileprivate struct AssociatedObjectKeys {
        static var buttonTap = "UIButton-tapGestureRecognizer"
    }

    fileprivate var buttonTapAction: UIButtonTapAction? {
        set {
            setAssociatedObject(key: &AssociatedObjectKeys.buttonTap, value: newValue as Any?)
        }
        get {
            return getAssociatedObject(key: &AssociatedObjectKeys.buttonTap) as? UIButtonTapAction
        }
    }

    @discardableResult
    func onTouchUpInside(_ closure: UIButtonTapAction) -> UIButton {
        self.buttonTapAction = closure
        self.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return self
    }

    @objc private func handleTap() {
        guard let buttonTapAction = buttonTapAction else {
            return
        }
        buttonTapAction?(self)
    }



}



// MARK: - Animations

//class DeclarativeAnimationState {
//    private var endedClosure: (()->())?
//
//    func ended(_ closure: @escaping ()->()) {
//        self.endedClosure = closure
//    }
//}
//
//enum DeclarativeAnimation {
//    case defaultAnimation(duration: Double)
//}
//
//
//extension UIView {
//
//    @discardableResult
//    func animate(animationType: DeclarativeAnimation = .defaultAnimation(duration: 1.0), animations: ()->()) -> DeclarativeAnimationState {
//        let
//
//        return
//    }
//}


// MARK: - Anima

