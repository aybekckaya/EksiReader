//
//  KeyboardHandler.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 12.03.2022.
//

import Foundation
import UIKit

// MARK: - Keyboard Handler
class KeyboardHandler {
    private var _scrollView: UIScrollView?
    private var _activeTextfield: UITextField?
    private var _activeTextView: UITextView?
    private var _keyboardFrame: CGRect?

    @discardableResult
    func scrollView(_ value: UIScrollView?) -> KeyboardHandler {
        self._scrollView = value
        return self
    }

    @discardableResult
    func activeTextfield(_ value: UITextField?) -> KeyboardHandler {
        self._activeTextfield = value
        return self
    }

    @discardableResult
    func activeTextView(_ value: UITextView?) -> KeyboardHandler {
        self._activeTextView = value
        return self
    }

    @discardableResult
    func keyboardFrame(_ value: CGRect?) -> KeyboardHandler {
        self._keyboardFrame = value
        return self
    }

//    self.scrollView.contentInset = .init(top: 0, left: 0, bottom: 300, right: 0)
//    self.scrollView.scrollRectToVisible(textfield.frame, animated: true)
    func moveRectToVisible() {
        guard
            let _keyboardFrame = _keyboardFrame
        else { return }

        if let _ = activeFieldFrame() {
            setContentInsetBottom(_keyboardFrame.size.height + 64)
        } else {
            setContentInsetBottom(0)
        }
    }

    private func setContentInsetBottom(_ value: CGFloat) {
        guard
            let _scrollView = _scrollView
        else { return }
        var currentInsets = _scrollView.contentInset
        currentInsets.bottom = value
        Anima
            .animate(with: .defaultAnimation(duration: 0.3, options: .curveEaseInOut)) {
                _scrollView.contentInset = currentInsets
            }.start()
    }

    private func activeFieldFrame() -> CGRect? {
        if let _activeTextfield = _activeTextfield {
            return _activeTextfield.frame
        } else if let _activeTextView = _activeTextView {
            return _activeTextView.frame
        }
        return nil
    }


}
