//
//  SettingsDetailViewController.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

class SettingDetailViewController: ERViewController, ERViewControllerReloadable {
    private let viewModel: SettingsDetailViewModel

    private let scrollableView = ScrollableView
        .scrollableView(axis: .vertical)
    
    private var inputsDictionary: [String: UIView] = [:]

    init(viewModel: SettingsDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadViews() {
        super.reloadViews()
        inputsDictionary.compactMap { key, value in
            return value as? ERViewReloadable
        }.forEach {
            $0.reloadView()
        }
        self.reloadChildren()
    }
}

// MARK: - Lifecycle
extension SettingDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()
        viewModel.initialize()
    }
}

// MARK: - Set Up UI
extension SettingDetailViewController {
    private func setUpUI() {
        scrollableView
            .add(into: self.view)
            .fit()
    }
    
    private func addSpace(_ height: CGFloat) {
        let viewSpace = UIView
            .view()
            .height(.constant(height))
            .backgroundColor(.clear)
        scrollableView.insert(viewSpace)
    }
}

// MARK: - Listeners
extension SettingDetailViewController {
    private func addListeners() {
        
        viewModel.changeHandler = { [weak self] change in
            switch change {
            case .presentation(let presentation):
                self?.handlePresentation(presentation)
            case .title(let title):
                self?.setTitle(title)
            case .reload(let presentation):
                self?.reload(presentation)
            }
        }
    }
    
    
}

// MARK: - Handle Presentation
extension SettingDetailViewController {
    private func handlePresentation(_ presentation: SettingsDetailPresentation) {
        inputsDictionary = [:]
        self.addSpace(48)
        presentation.sections.forEach { section in
            self.addSpace(24)
            section.inputs.forEach { input in
                self.addInput(input)
                self.addSpace(1.0)
            }
        }
    }
    
    private func reload(_ presentation: SettingsDetailPresentation) {
        presentation.sections.forEach { section in
            section.inputs.forEach { input in
                let viewElement = self.inputsDictionary[input.identifier]
                if let switchElement = viewElement as? SwitcherInputView, let switchPresentation = input as? SwitcherInputPresentation {
                    switchElement.setIsOn(value: switchPresentation.isOn , isAnimated: true)
                    switchElement.setIsEnabled(value: switchPresentation.isEnabled, isAnimated: true)
                } else if let tickElement = viewElement as? TickInputView, let tickPresentation = input as? TickInputPresentation {
                    tickElement.setIsChecked(tickPresentation.isChecked)
                    tickElement.setIsEnabled(value: tickPresentation.isEnabled, isAnimated: true)
                }
            }
        }
    }
    
    private func addInput(_ input: SettingsDetailInputPresentation) {
        if let switchInput = input as? SwitcherInputPresentation {
            let view = SwitcherInputView()
            view.configure(title: switchInput.title, isOn: switchInput.isOn)
            view.setIsEnabled(value: switchInput.isEnabled, isAnimated: false)
            scrollableView.insert(view)
            view.listen { [weak self] value in
                guard let self = self else { return }
                self.viewModel.valueChanged(identifier: input.identifier, newValue: value)
            }
            inputsDictionary[switchInput.identifier] = view
        } else if let tickInput = input as? TickInputPresentation {
            let view = TickInputView()
            view.configure(title: tickInput.title, isChecked: tickInput.isChecked)
            view.setIsEnabled(value: tickInput.isEnabled, isAnimated: false)
            scrollableView.insert(view)
            view.listen {
                self.viewModel.valueChanged(identifier: tickInput.identifier, newValue: nil)
            }
            inputsDictionary[tickInput.identifier] = view
        }
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

