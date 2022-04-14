//
//  TopicCell.swift
//  EksiReader
//
//  Created by aybek can kaya on 14.04.2022.
//

import Foundation
import UIKit

class TopicCell: UITableViewCell, ERListCell {
    typealias T = TopicEntryPresentation

    private let lblContent = UILabel
        .label()
        .font(Styling.TopicCell.contentLabelFont)
        .textColor(Styling.TopicCell.contentColor)
        .alignment(.left)
        .numberOfLines(0)


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        lblContent
            .add(into: self)
            .leading(.constant(16))
            .trailing(.constant(16))
            .bottom(.constant(16))
            .top(.constant(16))
    }

    func configure(with item: TopicEntryPresentation) {
        lblContent.attributedText = item.content.attributedTodayTitle()
    }


}
