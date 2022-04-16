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
class TopicCellInfoView: UIView {

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
        .backgroundColor(.systemGray)
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

//        labelsStackView
//            .add(intoStackView: mainStackView)

//        UIView
//            .view()
//            .add(intoStackView: labelsStackView)

        lblDate
            .add(intoStackView: labelsStackView)

        lblNick
            .add(intoStackView: labelsStackView)
           // .height(.constant(14))

//        UIView
//            .view()
//            .add(intoStackView: labelsStackView)

        lblNick.text = "Aybek Can Kaya"
        lblDate.text = "12/03/2020 14:43"

//        let sampleLabelView = UIView
//            .view()
//            .add(intoStackView: labelsStackView)
//            .height(.constant(64))
//            .backgroundColor(.green)


        imViewProfile
            .add(intoStackView: mainStackView)
            .width(.constant(Styling.TopicCell.imageViewEdgeSize))
            .height(.constant(Styling.TopicCell.imageViewEdgeSize))
            .roundCorners(by: Styling.TopicCell.imageViewEdgeSize / 2, maskToBounds: true)
    }

    func configure(date: String, nick: String, profileURL: String?) {
        lblNick.text = nick
        lblDate.text = date
        imViewProfile.setImage(with: profileURL)
    }
}

// MARK: - Declarative UI
extension TopicCellInfoView {
    static func topicCellInfoView() -> TopicCellInfoView {
        let view = TopicCellInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false 
        return view
    }
}

extension UIView {
    func asTopicCellInfoView() -> TopicCellInfoView {
        return self as! TopicCellInfoView
    }
}
