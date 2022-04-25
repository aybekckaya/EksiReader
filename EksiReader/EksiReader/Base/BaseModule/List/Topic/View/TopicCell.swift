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
    typealias T = TopicItemPresentation

    private let entryContentView = EntryContentView
        .entryContentView()

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
        entryContentView
            .add(into: self.contentView)
            .fit()

        UIView
            .view()
            .backgroundColor(Styling.TopicListCell.separatorColor)
            .add(into: self)
            .bottom(.constant(0))
            .leading(.constant(0))
            .trailing(.constant(0))
            .height(.constant(0.5))
    }
}

// MARK: - Public
extension TopicCell {
    func setDelegate(_ value: EntryContentViewDelegate) {
        entryContentView.setDelegate(value)
    }

    func configure(with item: TopicItemPresentation) {
        entryContentView.configure(with: item)
        if item.isAuthorBlocked {
            entryContentView.alpha = 0.3
        } else {
            entryContentView.alpha = 1.0
        }
    }
}


