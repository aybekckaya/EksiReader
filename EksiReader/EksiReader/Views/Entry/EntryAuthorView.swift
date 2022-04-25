//
//  TopicCellInfoVie.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation
import UIKit
import Kingfisher

// MARK: - TopicCellInfoView
class EntryAuthorView: UIView {

    private let mainStackView = UIStackView
        .stackView(alignment: .fill, distribution: .fill, spacing: 8, axis: .horizontal)

    private let labelsStackView = UIStackView
        .stackView(alignment: .fill, distribution: .fill, spacing: 4, axis: .vertical)

    private let lblDate = UILabel
        .label()
        .font(Styling.TopicCell.dateLabelFont)
        .textColor(Styling.TopicCell.dateLabelTextColor)
        .alignment(.right)

    private let lblNick = UILabel
        .label()
        .font(Styling.TopicCell.nickLabelFont)
        .textColor(Styling.TopicCell.nickLabelTextColor)
        .alignment(.right)

    private let imViewProfile = UIImageView
        .imageView()
        .contentMode(.scaleAspectFill)
        .clipToBounds(true)
        .backgroundColor(Styling.TopicCell.imageViewBGColor)
        .asImageView()


    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }
}

// MARK: - Set Up UI
extension EntryAuthorView {
    private func setUpUI() {
        self.backgroundColor = .clear

        mainStackView
            .add(into: self)
            .fit()

        let labelsContainerView = UIView
            .view()
            .add(intoStackView: mainStackView)
            .backgroundColor(.clear)

        labelsStackView
            .add(into: labelsContainerView)
            .trailing(.constant(0))
            .centerY(.constant(0))

        lblDate
            .add(intoStackView: labelsStackView)

        lblNick
            .add(intoStackView: labelsStackView)

        imViewProfile
            .add(intoStackView: mainStackView)
            .width(.constant(Styling.TopicCell.imageViewEdgeSize))
            .height(.constant(Styling.TopicCell.imageViewEdgeSize))
            .roundCorners(by: Styling.TopicCell.imageViewEdgeSize / 2, maskToBounds: true)
    }
}

// MARK: - Public
extension EntryAuthorView {
    func configure(date: String, nick: String, profileURL: String?) {
        imViewProfile.image = nil 
        lblNick.text = nick
        lblDate.text = date
        imViewProfile.setImage(with: profileURL)
    }
}

// MARK: - Declarative UI
extension EntryAuthorView {
    static func topicCellInfoView() -> EntryAuthorView {
        let view = EntryAuthorView()
        view.translatesAutoresizingMaskIntoConstraints = false 
        return view
    }
}

extension UIView {
    func asTopicCellInfoView() -> EntryAuthorView {
        return self as! EntryAuthorView
    }
}
