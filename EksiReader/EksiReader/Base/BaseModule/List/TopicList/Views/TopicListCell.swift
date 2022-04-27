//
//  TodayCell.swift
//  EksiReader
//
//  Created by aybek can kaya on 11.04.2022.
//

import Foundation
import UIKit

class TopicListCell: UITableViewCell, ERListCell {

    typealias T = TopicListItemPresentation

    private let lblTitle = UILabel
        .label()
        .font(Styling.TopicListCell.titleFont)
        .textColor(Styling.TopicListCell.titleColor)
        .alignment(.left)
        .numberOfLines(0)

    private let lblCount = UILabel
        .label()
        .font(Styling.TopicListCell.countLabelFont)
        .textColor(Styling.TopicListCell.countLabelColor)
        .alignment(.right)

    private let viewFollowSign = UIView
        .view()
        .backgroundColor(Styling.TopicListCell.followSignColor)

    private let followContainerView = UIView
        .view()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        self.backgroundColor = Styling.Application.backgroundColor

        let stackViewRight = UIStackView
            .stackView(alignment: .fill, distribution: .fill, spacing: 0, axis: .horizontal)

        stackViewRight
            .add(into: self)
            .trailing(.constant(8))
            .centerY(.constant(0))
            .height(.constant(16))

        lblCount
            .add(intoStackView: stackViewRight)
            .width(.min(48))

        followContainerView
            .add(intoStackView: stackViewRight)
            .width(.constant(16))

        viewFollowSign
            .add(into: followContainerView)
            .width(.constant(8))
            .height(.constant(8))
            .centerX(.constant(0))
            .centerY(.constant(1))

        viewFollowSign
            .roundCorners(by: 4)

        lblTitle
            .add(into: self)
            .leading(.constant(16))
            .top(.constant(Styling.TopicListCell.verticalMargin))
            .bottom(.constant(Styling.TopicListCell.verticalMargin))

        lblTitle.trailingAnchor.constraint(equalTo: stackViewRight.leadingAnchor, constant: 0).isActive = true

        UIView
            .view()
            .backgroundColor(Styling.TopicListCell.separatorColor)
            .add(into: self)
            .bottom(.constant(0))
            .leading(.constant(0))
            .trailing(.constant(0))
            .height(.constant(0.5))
    }

    func configure(with item: TopicListItemPresentation) {
        lblTitle.attributedText = item.attributedTitle
        lblCount.text = "(\(item.count))"
        followContainerView.isHidden = !item.isFollowing
    }

//    func configure(_ item: TodayPresentation) {
//        lblTitle.attributedText = item.attributedTitle
//        lblCount.text = "(\(item.count))"
//
////        let length = Int.random(in: 50 ..< 1000)
////        lblTitle.text = String.random(length: length)
//    }
}


extension String {
    static func random(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}
