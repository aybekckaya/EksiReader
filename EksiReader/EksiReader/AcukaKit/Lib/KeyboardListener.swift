//
//  KeyboardListener.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 12.03.2022.
//

import Foundation
import UIKit

typealias KeyboardListenerClosure = (CGRect, TimeInterval)->()
class KeyboardListener {
    fileprivate static let shared = KeyboardListener()

    static var instance: KeyboardListener {
        KeyboardListener.shared
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @discardableResult
    func releaseNotifications() -> KeyboardListener {
        NotificationCenter.default.removeObserver(self)
        return self
    }

    @discardableResult
    func onWillShow(_ closure: @escaping KeyboardListenerClosure) -> KeyboardListener {
        addNotification(UIResponder.keyboardWillShowNotification,
                        closure: closure)
        return self
    }

    @discardableResult
    func onWillHide(_ closure: @escaping KeyboardListenerClosure) -> KeyboardListener {
        addNotification(UIResponder.keyboardWillHideNotification,
                        closure: closure)
        return self
    }

    @discardableResult
    func onDidShow(_ closure: @escaping KeyboardListenerClosure) -> KeyboardListener {
        addNotification(UIResponder.keyboardDidShowNotification,
                        closure: closure)
        return self
    }

    @discardableResult
    func onDidHide(_ closure: @escaping KeyboardListenerClosure) -> KeyboardListener {
        addNotification(UIResponder.keyboardDidHideNotification,
                        closure: closure)
        return self
    }

    private func addNotification(_ name: Notification.Name, closure: @escaping KeyboardListenerClosure) {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            self.callClosure(notificationUserInfo: notification.userInfo,
                             closure: closure)
        }
    }

    private func callClosure(notificationUserInfo: [AnyHashable: Any]?,
                             closure: KeyboardListenerClosure) {
        guard
            let userInfo = notificationUserInfo,
            let heightValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
         else {
             closure(.zero,0)
            return
        }

        let frame = heightValue.cgRectValue
        closure(frame, duration)
    }

}
