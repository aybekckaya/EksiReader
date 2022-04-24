//
//  EntryTextContentView.swift
//  EksiReader
//
//  Created by aybek can kaya on 18.04.2022.
//

import Foundation
import UIKit

class EntryTextContentView: UIView, UITextViewDelegate {

    private let textViewContent = UITextView
        .textview()
        .font(Styling.TopicCell.contentLabelFont)
        .textColor(Styling.TopicCell.contentColor)
        .alignment(.left)
        .isEditable(false)
        .scrollEnabled(false)
        .isSelectable(true)

    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        textViewContent
            .add(into: self)
            .leading(.constant(16))
            .trailing(.constant(16))
            .top(.constant(16))
            .bottom(.constant(16))
            .height(.min(1))
        textViewContent.dataDetectorTypes = .link
    }

    func configure(text: NSAttributedString) {
        textViewContent.attributedText = text
    }

//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        return true
//    }
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
