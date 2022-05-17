//
//  TopicFilterView.swift
//  EksiReader
//
//  Created by aybek can kaya on 26.04.2022.
//

import Foundation
import UIKit

class TopicFilterViewController: ERViewController {
    private let soritngType: ERListSortType
    private let isFollowingEntry: Bool

    private let sortInputView = TappableInputView
        .tappableInputView()

    private let watchInputView = TappableInputView
        .tappableInputView()


    init(soritngType: ERListSortType, isFollowingEntry: Bool) {
        self.soritngType = soritngType
        self.isFollowingEntry = isFollowingEntry
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()
    }

    private func setUpUI() {
        let stackView = UIStackView
            .stackView(alignment: .fill, distribution: .fillEqually, spacing: 8, axis: .vertical)

        stackView
            .add(into: self.view)
            .centerY(.constant(0))
            .leading(.constant(8))
            .trailing(.constant(8))

        sortInputView
            .add(intoStackView: stackView)
           // .height(.constant(72))

        let sortInputViewTitle = soritngType == .lastToFirst ? "Eskiden yeniye sırala" : "Yeniden eskiye sırala"
        sortInputView.configure(title: sortInputViewTitle ,
                                backgroundColor: .systemBlue,
                                image: UIImage(systemName: "arrow.up.arrow.down"))

        if C.Switch.topicFollowEnabled {
            watchInputView
                .add(intoStackView: stackView)
            
            let watchInputViewTitle = isFollowingEntry ? "Konuyu takibi bırak" : "Konuyu takip et"
            let watchInputViewColor = isFollowingEntry ? UIColor.systemRed : UIColor.systemBlue
            watchInputView.configure(title: watchInputViewTitle,
                                    backgroundColor: watchInputViewColor,
                                    image: UIImage(systemName: "eye"))
        }
    }

    private func addListeners() {
        watchInputView
            .onTap { _ in
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: ERKey.NotificationName.changedEntryFollowStatus, object: nil)
            }

        sortInputView
            .onTap { _ in
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: ERKey.NotificationName.changedSortingType, object: nil)
            }
    }
}

