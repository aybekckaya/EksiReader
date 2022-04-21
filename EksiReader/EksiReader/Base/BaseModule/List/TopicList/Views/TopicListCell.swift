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
        .font(Styling.TodaysCell.titleFont)
        .textColor(Styling.TodaysCell.titleColor)
        .alignment(.left)
        .numberOfLines(0)

    private let lblCount = UILabel
        .label()
        .font(Styling.TodaysCell.countLabelFont)
        .textColor(Styling.TodaysCell.countLabelColor)
        .alignment(.right)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        self.backgroundColor = Styling.Application.backgroundColor

        lblCount
            .add(into: self)
            .trailing(.constant(16))
            .top(.constant(Styling.TodaysCell.verticalMargin))
            .bottom(.constant(Styling.TodaysCell.verticalMargin))
            .width(.min(64))

        lblTitle
            .add(into: self)
            .leading(.constant(16))
            .top(.constant(Styling.TodaysCell.verticalMargin))
            .bottom(.constant(Styling.TodaysCell.verticalMargin))
            .margin(to: .left(of: lblCount, value: .constant(-16)))
    }

    func configure(with item: TopicListItemPresentation) {
        lblTitle.attributedText = item.attributedTitle
        lblCount.text = "(\(item.count))"
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
