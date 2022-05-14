//
//  TopicCellInputView.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation
import UIKit

protocol EntryInputViewDelegate: AnyObject {
    func entryInputViewShareDidTapped(_ view: EntryInputView)
    func entryInputViewFavoriteDidTapped(_ view: EntryInputView)
    func entryInputViewReportDidTapped(_ view: EntryInputView)
}

// MARK: - TopicCellInputItemView
class EntryInputItemView: UIView {
    private let imView = UIImageView
        .imageView()
        .tintColor(Styling.TopicCell.inputItemViewTintColor)
        .contentMode(.scaleAspectFill)
        .clipToBounds(true)

    private let lblValue = UILabel
        .label()
        .font(C.Font.regular.font(size: 12))
        .textColor(Styling.TopicCell.inputItemViewTintColor)
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

    func updateTheme() {
        lblValue.textColor(Styling.TopicCell.inputItemViewTintColor)
        imView.tintColor(Styling.TopicCell.inputItemViewTintColor)
    }
}

extension EntryInputItemView {
    static func topicCellInputItemView() -> EntryInputItemView {
        let view = EntryInputItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asTopicCellInputItemView() -> EntryInputItemView {
        return self as! EntryInputItemView
    }
}


// MARK: - TopicCellInputView
class EntryInputView: UIView {
    private weak var delegate: EntryInputViewDelegate?

    private let favoriteItemView = EntryInputItemView
        .topicCellInputItemView()

    private let shareItemView = EntryInputItemView
        .topicCellInputItemView()

    private let reportItemView = EntryInputItemView
        .topicCellInputItemView()

    private let attachItemView = EntryInputItemView
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
extension EntryInputView {
    private func setUpUI() {
        backgroundColor = .clear

        let stackView = UIStackView
            .stackView(alignment: .fill, distribution: .fill, spacing: 48, axis: .horizontal)
            .add(into: self)
            .leading(.constant(0))
            .trailing(.constant(0))
            .height(.constant(20))
            .centerY(.constant(0))
            .asStackView()

        favoriteItemView
            .add(intoStackView: stackView)
            .onTap { _ in
                NSLog("Favorite Tapped")
                self.delegate?.entryInputViewFavoriteDidTapped(self)
            }

        attachItemView
            .add(intoStackView: stackView)

        shareItemView
            .add(intoStackView: stackView)
            .onTap { _ in
                self.delegate?.entryInputViewShareDidTapped(self)
            }

        reportItemView
            .add(intoStackView: stackView)
            .onTap { _ in
                self.delegate?.entryInputViewReportDidTapped(self)
            }
    }
}

// MARK: - Public
extension EntryInputView {
    func updateTheme() {
        favoriteItemView.updateTheme()
        attachItemView.updateTheme()
        shareItemView.updateTheme()
        reportItemView.updateTheme()
    }

    func configure(favoriteCount: Int, isFavoritedByUser: Bool, attachmentCount: Int, delegate: EntryInputViewDelegate) {
        self.delegate = delegate
        favoriteItemView
            .configure(image: isFavoritedByUser ? "heart.fill" : "heart", value: "\(favoriteCount)")

        shareItemView
            .configure(image: "square.and.arrow.up", value: nil)

        reportItemView
            .configure(image: "flag", value: nil)

        attachItemView
            .configure(image: "paperclip", value: "\(attachmentCount)")

        if attachmentCount == 0 {
            attachItemView.isHidden = true
        } else {
            attachItemView.isHidden = false
        }
    }
}


// MARK: -
extension EntryInputView {

}


// MARK: -
extension EntryInputView {

}


// MARK: -
extension EntryInputView {

}

// MARK: - Declarative UI
extension EntryInputView {
    static func topicCellInputView() -> EntryInputView {
        let view = EntryInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asTopicCellInputView() -> EntryInputView {
        return self as! EntryInputView
    }
}

