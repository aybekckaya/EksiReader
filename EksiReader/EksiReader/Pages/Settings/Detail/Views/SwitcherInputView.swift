//
//  SwitcherInputView.swift
//  EksiReader
//
//  Created by Kaya, Can(AWF) on 4.05.2022.
//

import Foundation
import UIKit

class SwitcherInputView: UIView {
    private let viewContent = UIView
        .view()
        .backgroundColor(Styling.SettingsDetailView.containterViewBackgroundColor)

    private let lblTitle = UILabel
        .label()
        .font(Styling.SettingsDetailView.itemTitleFont)
        .textColor(Styling.SettingsDetailView.itemTitleColor)

    private let switcher = UISwitch
        .switcher()
    
    private var callback: ((Bool) -> Void)?

    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        viewContent
            .add(into: self)
            .fit()
            .height(.constant(64))
        
        switcher
            .add(into: viewContent)
            .trailing(.constant(16))
            .centerY(.constant(0))

        lblTitle
            .add(into: viewContent)
            .leading(.constant(16))
            .centerY(.constant(0))
            .margin(to: .left(of: switcher, value: .constant(16)))
    }

    func configure(title: String, isOn: Bool) {
        lblTitle.text = title
        switcher.setOn(isOn, animated: false)
        switcher.addTarget(self, action: #selector(switcherValueChanged), for: .valueChanged)
    }
    
    func setIsOn(value: Bool, isAnimated: Bool) {
        switcher.setOn(value, animated: isAnimated)
    }
    
    func setIsEnabled(value: Bool, isAnimated: Bool) {
        self.alpha = value ? 1.0 : 0.4
    }
    
    func listen(_ callback: ((Bool) -> Void)?) {
        self.callback = callback
    }
    
    @objc private func switcherValueChanged() {
        self.callback?(switcher.isOn)
    }
}

