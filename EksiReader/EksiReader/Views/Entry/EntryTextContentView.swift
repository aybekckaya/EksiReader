//
//  EntryTextContentView.swift
//  EksiReader
//
//  Created by aybek can kaya on 18.04.2022.
//

import Foundation
import UIKit

class EntryTextContentView: UIView {

    private let lblContent = UILabel
        .label()
        .font(Styling.TopicCell.contentLabelFont)
        .textColor(Styling.TopicCell.contentColor)
        .alignment(.left)
        .numberOfLines(0)

    init() {
        super.init(frame: .zero)
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
            .top(.constant(16))
            .bottom(.constant(16))
    }

    func configure(text: NSAttributedString) {
        lblContent.attributedText = text
    }
}

// MARK: - Declarative UI
extension EntryTextContentView {
    static func entryTextContentView() -> EntryTextContentView {
        let view = EntryTextContentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asEntryTextContentView() -> EntryTextContentView {
        return self as! EntryTextContentView
    }
}
