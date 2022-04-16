//
//  TopicCellInputView.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation
import UIKit

protocol TopicCellInputViewDelegate: AnyObject {
    func topicCellInputViewShareDidTapped(_ view: TopicCellInputView)
    func topicCellInputViewFavoriteDidTapped(_ view: TopicCellInputView)
}

// MARK: - TopicCellInputItemView
class TopicCellInputItemView: UIView {
    private let imView = UIImageView
        .imageView()
        .tintColor(.white)
        .contentMode(.scaleAspectFill)
        .clipToBounds(true)

    private let lblValue = UILabel
        .label()
        .font(C.Font.regular.font(size: 12))
        .textColor(.white)
        .alignment(.left)

    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        let stackView = UIStackView
            .stackView(alignment: .fill, distribution: .fill, spacing: 2, axis: .horizontal)
            .add(into: self)
            .fit()
            .asStackView()

        imView
            .add(intoStackView: stackView)
            .width(.constant(20))

        lblValue
            .add(intoStackView: stackView)
    }

    func configure(image: String, value: String?) {
        let imageObject = UIImage(systemName: image)
        imView.image = imageObject
        lblValue.isHidden = value == nil
        lblValue.text = value ?? ""
    }
}

extension TopicCellInputItemView {
    static func topicCellInputItemView() -> TopicCellInputItemView {
        let view = TopicCellInputItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asTopicCellInputItemView() -> TopicCellInputItemView {
        return self as! TopicCellInputItemView
    }
}


// MARK: - TopicCellInputView
class TopicCellInputView: UIView {
    private weak var delegate: TopicCellInputViewDelegate?

    private let favoriteItemView = TopicCellInputItemView
        .topicCellInputItemView()

    private let shareItemView = TopicCellInputItemView
        .topicCellInputItemView()


    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Set Up UI
extension TopicCellInputView {
    private func setUpUI() {
        backgroundColor = .clear

        let stackView = UIStackView
            .stackView(alignment: .fill, distribution: .fill, spacing: 16, axis: .horizontal)
            .add(into: self)
            .trailing(.constant(4))
            .height(.constant(20))
            .centerY(.constant(0))
            .asStackView()

        favoriteItemView
            .add(intoStackView: stackView)
            .onTap { _ in
                self.delegate?.topicCellInputViewFavoriteDidTapped(self)
            }

        shareItemView
            .add(intoStackView: stackView)
            .onTap { _ in
                self.delegate?.topicCellInputViewShareDidTapped(self)
            }
    }
}

// MARK: - Public
extension TopicCellInputView {
    func configure(favoriteCount: Int, isFavoritedByUser: Bool, delegate: TopicCellInputViewDelegate) {
        self.delegate = delegate
        favoriteItemView
            .configure(image: isFavoritedByUser ? "heart.fill" : "heart", value: "\(favoriteCount)")

        shareItemView
            .configure(image: "square.and.arrow.up", value: nil)
    }
}


// MARK: -
extension TopicCellInputView {

}


// MARK: -
extension TopicCellInputView {

}


// MARK: -
extension TopicCellInputView {

}

// MARK: - Declarative UI
extension TopicCellInputView {
    static func topicCellInputView() -> TopicCellInputView {
        let view = TopicCellInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asTopicCellInputView() -> TopicCellInputView {
        return self as! TopicCellInputView
    }
}

