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
    }
}

// MARK: - Public
extension TopicCell {
    func setDelegate(_ value: EntryContentViewDelegate) {
        entryContentView.setDelegate(value)
    }

    func configure(with item: TopicItemPresentation) {
        entryContentView.configure(with: item)
    }
}


