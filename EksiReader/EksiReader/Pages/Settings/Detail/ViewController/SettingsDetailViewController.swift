//
//  SettingsDetailViewController.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

class SwitcherInputView: UIView {
    private let viewContent = UIView
        .view()
        .backgroundColor(Styling.SettingsDetailView)

    private let lblTitle = UILabel
        .label()
        .font(Styling.SettingsDetailView.itemTitleFont)
        .textColor(Styling.SettingsDetailView.itemTitleColor)

    private let switcher = UISwitch
        .switcher()


    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        switcher
            .add(into: self)
            .trailing(.constant(16))
            .centerY(.constant(0))

        lblTitle
            .add(into: self)
            .leading(.constant(16))
            .
    }

    func configure(title: String, isOn: Bool) {

    }
}


class SettingDetailViewController: ERViewController {
    private let viewModel: SettingsDetailViewModel

    private let scrollableView = ScrollableView
        .scrollableView(axis: .vertical)

    init(viewModel: SettingsDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension SettingDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()
    }
}

// MARK: - Set Up UI
extension SettingDetailViewController {
    private func setUpUI() {
        scrollableView
            .add(into: self.view)
            .fit()


        let viewSpace = UIView
            .view()
            .height(.constant(64))
            .backgroundColor(.clear)

        let viewElement = UIView
            .view()
            .height(.constant(64))
            .backgroundColor(Styling.SettingsDetailView.containterViewBackgroundColor)

        scrollableView.insertViews([viewSpace, viewElement])
    }
}

// MARK: - Listeners
extension SettingDetailViewController {
    private func addListeners() {

    }
}

// MARK: -
extension SettingDetailViewController {

}

// MARK: -
extension SettingDetailViewController {

}

// MARK: -
extension SettingDetailViewController {

}

// MARK: -
extension SettingDetailViewController {

}

// MARK: -
extension SettingDetailViewController {

}

// MARK: -
extension SettingDetailViewController {

}

// MARK: -
extension SettingDetailViewController {

}

