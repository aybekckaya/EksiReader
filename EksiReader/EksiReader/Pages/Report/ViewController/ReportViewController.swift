//
//  ReportViewController.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation
import UIKit

fileprivate class ReportInputView: UIView {
    private let contentView = UIView
        .view()

    private let lblTitle = UILabel
        .label()
        .font(C.Font.bold.font(size: 15))
        .textColor(.white)
        .alignment(.center)

    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        contentView
            .add(into: self)
            .top(.constant(8))
            .leading(.constant(24))
            .trailing(.constant(24))
            .bottom(.constant(8))
            .height(.constant(48))

        contentView.roundCorners(by: 8)

        lblTitle
            .add(into: contentView)
            .fit()
    }

    func configure(title: String, backgroundColor: UIColor) {
        contentView.backgroundColor = backgroundColor
        lblTitle.text = title
    }
}

class ReportViewController: ERViewController {
    private let viewModel: ReportViewModel

    private let authorView = AuthorView
        .authorView()

    private let inputViewBlockUser = ReportInputView()

    let stackView = UIStackView
        .stackView(alignment: .fill, distribution: .fill, spacing: 0, axis: .vertical)

    init(viewModel: ReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension ReportViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()
        viewModel.initialize()
    }
}

// MARK: - Set Up UI
extension ReportViewController {
    private func setUpUI() {
        self.view.backgroundColor = Styling.Application.backgroundColor

        stackView
            .add(into: self.view)
            .leading(.constant(0))
            .trailing(.constant(0))
            .top(.constant(0))
            .height(.min(1))
            .bottom(.constant(36))

        authorView
            .add(intoStackView: stackView)

        inputViewBlockUser
            .add(intoStackView: stackView)

        inputViewBlockUser
            .onTap { _ in
                self.viewModel.toggleAuthorBlockState()
            }

    }
}

// MARK: - Listeners
extension ReportViewController {
    private func addListeners() {
        viewModel.change = {[weak self] change in
            switch change {
            case .presentation(let presentation):
                self?.handlePresentation(presentation)
            }
        }
    }
}

// MARK: - Handle Presentation
extension ReportViewController {
    private func handlePresentation(_ presentation: ReportPresentation) {
        self.authorView.configure(nick: presentation.authorNick,
                                   avatarURL: presentation.authorAvatarURL)

        let blockTitle = presentation.isBlocked ? "Engeli Kaldır" : "Kullanıcıyı Engelle"
        let blockBGColor = presentation.isBlocked ? UIColor.systemBlue : UIColor.systemRed
        inputViewBlockUser.configure(title: blockTitle, backgroundColor: blockBGColor)
    }
}

// MARK: -
extension ReportViewController {

}

// MARK: -
extension ReportViewController {

}

// MARK: -
extension ReportViewController {

}

// MARK: -
extension ReportViewController {

}

// MARK: -
extension ReportViewController {

}

