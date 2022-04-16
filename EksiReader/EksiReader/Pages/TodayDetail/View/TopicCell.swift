//
//  TopicCell.swift
//  EksiReader
//
//  Created by aybek can kaya on 14.04.2022.
//

import Foundation
import UIKit


// MARK: - TopicCell
class TopicCell: UITableViewCell, ERListCell {
    typealias T = TopicEntryPresentation

    private let lblContent = UILabel
        .label()
        .font(Styling.TopicCell.contentLabelFont)
        .textColor(Styling.TopicCell.contentColor)
        .alignment(.left)
        .numberOfLines(0)

    private let infoView = TopicCellInfoView
        .topicCellInfoView()

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
            //.bottom(.constant(16))
            .top(.constant(16))

        infoView
            .add(into: self)
            .margin(to: .bottom(of: lblContent, value: .constant(8)))
            .align(with: .right(of: lblContent, value: .constant(0)))
            .height(.min(1)) // add Min
            .ratio(to: .width(of: self, value: 0.5))
            .bottom(.constant(8))
    }

    func configure(with item: TopicEntryPresentation) {
        lblContent.attributedText = item.content.attributedTodayTitle()
        infoView.configure(date: item.createdDatePresentable, nick: item.authorName, profileURL: item.authorImageURL)
    }


}
