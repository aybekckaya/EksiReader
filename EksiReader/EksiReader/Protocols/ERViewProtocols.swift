//
//  ERViewProtocols.swift
//  EksiReader
//
//  Created by aybek can kaya on 18.04.2022.
//

import Foundation
import UIKit

// MARK: - ERListCell
protocol ERListCell where Self: UITableViewCell {
    associatedtype T
    func configure(with item: T)
}

// MARK: - Pagable Presentation
protocol PagablePresentation {
    associatedtype PresentationEntry
    init(entry: PresentationEntry)
}

//protocol ERListableViewProtocol {
//
//}
//
//class ERListViewController<>: ERViewController {
//
//}
