//
//  ToastView.swift
//  EksiReader
//
//  Created by Kaya, Can(AWF) on 17.05.2022.
//

import Foundation
import Toaster
import UIKit

class ERToast {
    
    private func updateTheme() {
        ToastView.appearance().backgroundColor = Styling.ToastView.backgroundColor
        ToastView.appearance().textColor = Styling.ToastView.textColor
        ToastView.appearance().font = Styling.ToastView.textFont
    }
    
    static func show(with message: String) {
        let toastView = ERToast()
        toastView.updateTheme()
        
        ToastCenter.default.cancelAll()
        Toast(text: message, duration: Delay.short)
            .show()
    }
}
