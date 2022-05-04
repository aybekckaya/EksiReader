//
//  TickInputView.swift
//  EksiReader
//
//  Created by Kaya, Can(AWF) on 4.05.2022.
//

import Foundation
import UIKit

class TickInputView: UIView {
    private let viewContent = UIView
        .view()
        .backgroundColor(Styling.SettingsDetailView.containterViewBackgroundColor)

    private let lblTitle = UILabel
        .label()
        .font(Styling.SettingsDetailView.itemTitleFont)
        .textColor(Styling.SettingsDetailView.itemTitleColor)
    
    private let imViewTick = UIImageView
        .imageView()
        .tintColor(.cyan)
        .contentMode(.scaleAspectFit)
    
    private var callback: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        imViewTick.image = UIImage(systemName: "checkmark")
        viewContent
            .add(into: self)
            .fit()
            .height(.constant(64))
        
        imViewTick
            .add(into: viewContent)
            .trailing(.constant(16))
            .centerY(.constant(0))
            .height(.constant(18))
            .width(.constant(18))

        lblTitle
            .add(into: viewContent)
            .leading(.constant(16))
            .trailing(.constant(64))
            .centerY(.constant(0))
        
        viewContent.onTap { [weak self] _ in
            guard self?.alpha == 1.0 else { return }
            self?.itemSelected()
        }
    }
    
    func configure(title: String, isChecked: Bool) {
        lblTitle.text = title
        imViewTick.isHidden = !isChecked
    }
    
    func setIsChecked(_ value: Bool) {
        imViewTick.isHidden = !value
    }
    
    func listen(_ callback: (() -> Void)?) {
        self.callback = callback
    }
    
    func setIsEnabled(value: Bool, isAnimated: Bool) {
        self.alpha = value ? 1.0 : 0.4
    }
    
    private func itemSelected() {
        self.callback?()
    }
}
