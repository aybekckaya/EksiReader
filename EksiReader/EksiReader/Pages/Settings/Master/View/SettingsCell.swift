//
//  SettingsCell.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

class SettingsCell: UITableViewCell {

    private let imViewIcon = UIImageView
        .imageView()
        .contentMode(.scaleAspectFit)
        .clipToBounds(true)
        .tintColor(Styling.SettingsView.Cell.iconColor)

    private let lblTitle = UILabel
        .label()
        .font(Styling.SettingsView.Cell.titleFont)
        .textColor(Styling.SettingsView.Cell.titleColor)
        .alignment(.left)
        .numberOfLines(1)

    private let lblDescription = UILabel
        .label()
        .font(Styling.SettingsView.Cell.descriptionFont)
        .textColor(Styling.SettingsView.Cell.descriptionColor)
        .alignment(.left)
        .numberOfLines(0)

    private let iconRightArrow = UIImageView
        .imageView()
        .contentMode(.scaleAspectFit)
        .clipToBounds(true)
        .tintColor(Styling.SettingsView.Cell.iconColor)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        backgroundColor = .clear

        imViewIcon
            .add(into: self)
            .leading(.constant(16))
            .centerY(.constant(0))
            .width(.constant(22))
            .height(.constant(22))

        iconRightArrow
            .add(into: self)
            .trailing(.constant(16))
            .centerY(.constant(0))
            .width(.constant(16))
            .height(.constant(16))

        iconRightArrow.image = UIImage(systemName: "chevron.right")

        let stackView = UIStackView
            .stackView(alignment: .fill, distribution: .fill, spacing: 8, axis: .vertical)

        stackView
            .add(into: self)
            .margin(to: .left(of: iconRightArrow, value: .constant(16)))
            .margin(to: .right(of: imViewIcon, value: .constant(16)))
            .top(.constant(8))
            .bottom(.constant(8))

        lblTitle
            .add(intoStackView: stackView)
        lblDescription
            .add(intoStackView: stackView)

        UIView
            .view()
            .add(into: self)
            .bottom(.constant(0))
            .leading(.constant(0))
            .trailing(.constant(0))
            .height(.constant(0.3))
            .backgroundColor(APP.themeManager.getCurrentTheme().separatorColor)
    }

    func configureCell(presentation: SettingsItemPresentation) {
        self.lblTitle.text = presentation.title
        self.lblDescription.attributedText = presentation.description
            .attributedString
            .lineHeight(1.2)
            .lineSpacing(6)
        self.imViewIcon.image = UIImage(systemName: presentation.icon)
    }
}
