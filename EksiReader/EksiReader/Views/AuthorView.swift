//
//  AuthorView.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation
import UIKit
import Kingfisher

class AuthorView: UIView {

    private let imViewAuthor = UIImageView
        .imageView()
        .contentMode(.scaleAspectFill)
        .clipToBounds(true)

    private let lblAuthorNick = UILabel
        .label()
        .font(Styling.ReportView.nickFont)
        .textColor(Styling.TopicCell.nickLabelTextColor)
        .alignment(.center)
        .numberOfLines(1)


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
        let stackView = UIStackView
            .stackView(alignment: .fill, distribution: .fill, spacing: 0, axis: .vertical)

        stackView
            .add(into: self)
            .top(.constant(0))
            .leading(.constant(0))
            .trailing(.constant(0))
            .height(.min(1))

        addImageView(in: stackView)
        addNickLabel(in: stackView)
    }

    private func addImageView(in stackView: UIStackView) {
        let authorImageContainerView = UIView
            .view()

        let imageViewSize: CGFloat = 120
        imViewAuthor
            .add(into: authorImageContainerView)
            .centerX(.constant(0))
            //.centerY(.constant(0))
            .height(.constant(imageViewSize))
            .width(.constant(imageViewSize))
            .top(.constant(24))
            .bottom(.constant(8))

        self.imViewAuthor.layer.cornerRadius =  imageViewSize / 2
        self.imViewAuthor.layer.masksToBounds = true

       authorImageContainerView
            .add(intoStackView: stackView)

        authorImageContainerView.backgroundColor = .clear
        imViewAuthor.backgroundColor = Styling.TopicCell.imageViewBGColor
    }

    private func addNickLabel(in stackView: UIStackView) {
        let authorNickContainerView = UIView
            .view()

        lblAuthorNick
            .add(into: authorNickContainerView)
            .centerX(.constant(0))
            .centerY(.constant(0))
            .top(.constant(8))
            .bottom(.constant(8))

        authorNickContainerView
            .add(intoStackView: stackView)
    }

    func configure(nick: String, avatarURL: String?) {
        self.lblAuthorNick.text = nick
        self.imViewAuthor.setImage(with: avatarURL)
    }

}

// MARK: - Declarative UI
extension AuthorView {
    static func authorView() -> AuthorView {
        let view = AuthorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asAuthorView() -> AuthorView {
        return self as! AuthorView
    }
}
