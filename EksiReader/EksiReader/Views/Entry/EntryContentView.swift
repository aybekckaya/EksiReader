//
//  EntryContentView.swift
//  EksiReader
//
//  Created by aybek can kaya on 18.04.2022.
//

import Foundation
import UIKit

protocol EntryContentViewDelegate: AnyObject {
    func entryContentViewDidTappedShare(_ view: EntryContentView, entryId: Int)
    func entryContentViewDidTappedFavorite(_ view: EntryContentView, entryId: Int)
    func entryContentViewDidTappedReport(_ view: EntryContentView, entryId: Int)
}

class EntryContentView: UIView {
    private weak var delegate: EntryContentViewDelegate?
    private var presentation: EntryPresentation?

    private let viewEntryText = EntryTextContentView
        .entryTextContentView()

    private let infoView = EntryAuthorView
        .topicCellInfoView()

    private let cellInputView = EntryInputView
        .topicCellInputView()


    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        viewEntryText
            .add(into: self)
            .leading(.constant(0))
            .trailing(.constant(0))
            .top(.constant(0))

        infoView
            .add(into: self)
            .margin(to: .bottom(of: viewEntryText, value: .constant(16)))
            .align(with: .right(of: viewEntryText, value: .constant(0)))
            .height(.min(1)) 
            .ratio(to: .width(of: self, value: 1.0))
            .onTap { _ in
                NSLog("YARRAKKKK")
            }

        cellInputView
            .add(into: self)
           // .leading(.constant(8))
            .margin(to: .bottom(of: infoView, value: .constant(16)))
            .bottom(.constant(8))
            .height(.constant(44))
            .align(with: .right(of: infoView, value: .constant(-8)))
    }

    func setDelegate(_ value: EntryContentViewDelegate) {
        self.delegate = value
    }

    func configure(with item: EntryPresentation) {
        self.presentation = item

        viewEntryText.configure(text: item.content)
        cellInputView.configure(favoriteCount: item.favoriteCount,
                                isFavoritedByUser: item.isFavorited,
                                attachmentCount: item.attachmentURLs.count,
                                delegate: self)
        infoView.configure(date: item.createdDatePresentable,
                           nick: item.authorName,
                           profileURL: item.authorImageURL)
    }
}


// MARK: - TopicCellInputViewDelegate
extension EntryContentView: EntryInputViewDelegate {
    func entryInputViewShareDidTapped(_ view: EntryInputView) {
        guard
            let delegate = delegate,
                let entryId = presentation?.id
        else {
            return
        }
        delegate.entryContentViewDidTappedShare(self, entryId: entryId)
    }

    func entryInputViewFavoriteDidTapped(_ view: EntryInputView) {
        guard
            let delegate = delegate,
                let entryId = presentation?.id
        else {
            return
        }
        delegate.entryContentViewDidTappedFavorite(self, entryId: entryId)
    }

    func entryInputViewReportDidTapped(_ view: EntryInputView) {
        guard
            let delegate = delegate,
                let entryId = presentation?.id
        else {
            return
        }
        delegate.entryContentViewDidTappedReport(self, entryId: entryId)
    }

}

// MARK: - Declarative UI
extension EntryContentView {
    static func entryContentView() -> EntryContentView {
        let view = EntryContentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asEntryContentView() -> EntryContentView {
        return self as! EntryContentView
    }
}
