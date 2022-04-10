//
//  ScrollableViewController.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 18.02.2022.
//

import Foundation
import UIKit

// MARK: - ScrollableViewController
class ScrollableViewController: UIViewController {
    private let childVCs: [UIViewController]

    private var scrollableView: ScrollableView?

    init(childViewControllers: [UIViewController]) {
        self.childVCs = childViewControllers
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        let viewScrollable = ScrollableView
            .scrollableView(axis: .vertical)
            .add(into: self.view)
            .fit()
            .asScrollableView()

        self.scrollableView = viewScrollable

        childVCs.forEach {
            let viewContainer = UIView
                .view()
                .backgroundColor(.clear)
            self.addChildViewController(childController: $0, onView: viewContainer)
            viewScrollable.insert(viewContainer)
        }

    }
}


