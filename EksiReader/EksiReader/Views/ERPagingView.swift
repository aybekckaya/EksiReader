//
//  ERPagingView.swift
//  EksiReader
//
//  Created by aybek can kaya on 23.04.2022.
//

import Foundation
import UIKit

class ERPagingView: UIView {
    private let contentView = UIView
        .view()

    private let lblTitle = UILabel
        .label()
        .font(Styling.PagingView.titleFont)
        .alignment(.center)
        .textColor(Styling.PagingView.textColor)

    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        self.backgroundColor(.clear)
        //translatesAutoresizingMaskIntoConstraints = false
        contentView
            .add(into: self)
            .fit()
            .backgroundColor(Styling.PagingView.backgroundColor)

        lblTitle
            .add(into: contentView)
            .fit()
    }

    public func updateTitle(currentPage: Int, totalPage: Int) {
        lblTitle.text = "\(currentPage) / \(totalPage)"
    }

    public func updateTheme() {
        contentView
            .backgroundColor(Styling.PagingView.backgroundColor)
        lblTitle
            .font(Styling.PagingView.titleFont)
            .alignment(.center)
            .textColor(Styling.PagingView.textColor)
    }
}

// MARK: - Declarative UI
extension ERPagingView {
    static func erPagingView() -> ERPagingView {
        let view = ERPagingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view 
    }
}

extension UIView {
    func asERPagingView() -> ERPagingView {
        return self as! ERPagingView
    }
}
