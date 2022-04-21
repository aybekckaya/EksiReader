//
//  ERViewController.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation
import UIKit

class ERViewController: UIViewController {

    private let titleView = ERNavigationTitleView
        .erNavigationTitleView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Styling.Application.backgroundColor
        self.navigationController?.navigationBar.tintColor = .white

        titleView.translatesAutoresizingMaskIntoConstraints = true
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        self.navigationItem.titleView = titleView
    }

    func setTitle(_ title: String?) {
        titleView.setTitle(title)
    }
}
