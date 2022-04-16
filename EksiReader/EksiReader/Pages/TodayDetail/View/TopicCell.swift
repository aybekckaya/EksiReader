//
//  TopicCell.swift
//  EksiReader
//
//  Created by aybek can kaya on 14.04.2022.
//

import Foundation
import UIKit

protocol TopicCellDelegate: AnyObject {
    func topicCellDidTappedShare(_ cell: TopicCell, entryId: Int)
    func topicCellDidTappedFavorite(_ cell: TopicCell, entryId: Int)
}

// MARK: - TopicCell
class TopicCell: UITableViewCell, ERListCell {
    typealias T = TopicEntryPresentation

    private weak var delegate: TopicCellDelegate?
    private var presentation: TopicEntryPresentation?

    private let lblContent = UILabel
        .label()
        .font(Styling.TopicCell.contentLabelFont)
        .textColor(Styling.TopicCell.contentColor)
        .alignment(.left)
        .numberOfLines(0)

    private let infoView = TopicCellInfoView
        .topicCellInfoView()

    private let cellInputView = TopicCellInputView
        .topicCellInputView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
extension TopicCell {
    private func setUpUI() {
        lblContent
            .add(into: self.contentView)
            .leading(.constant(16))
            .trailing(.constant(16))
            .top(.constant(16))

        infoView
            .add(into: self.contentView)
            .margin(to: .bottom(of: lblContent, value: .constant(8)))
            .align(with: .right(of: lblContent, value: .constant(0)))
            .height(.min(1)) // add Min
            .ratio(to: .width(of: self.contentView, value: 0.5))

        cellInputView
            .add(into: self.contentView)
            .leading(.constant(8))
            .margin(to: .bottom(of: infoView, value: .constant(8)))
            .bottom(.constant(8))
            .height(.constant(44))
            .align(with: .right(of: infoView, value: .constant(0)))
    }
}

// MARK: - TopicCellInputViewDelegate
extension TopicCell: TopicCellInputViewDelegate {
    func topicCellInputViewShareDidTapped(_ view: TopicCellInputView) {
        guard
            let delegate = delegate,
                let entryId = presentation?.id
        else {
            return
        }
        delegate.topicCellDidTappedShare(self, entryId: entryId)
    }

    func topicCellInputViewFavoriteDidTapped(_ view: TopicCellInputView) {
        guard
            let delegate = delegate,
                let entryId = presentation?.id
        else {
            return
        }
        delegate.topicCellDidTappedFavorite(self, entryId: entryId)
    }
}

// MARK: - Public
extension TopicCell {
    func setDelegate(_ value: TopicCellDelegate) {
        self.delegate = value
    }

    func configure(with item: TopicEntryPresentation) {
        self.presentation = item
        lblContent.attributedText = item.content.attributedTodayTitle()
        cellInputView.configure(favoriteCount: item.favoriteCount,
                                isFavoritedByUser: item.isFavorited,
                                delegate: self)
        infoView.configure(date: item.createdDatePresentable, nick: item.authorName, profileURL: item.authorImageURL)
    }
}


