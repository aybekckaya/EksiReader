//
//  File.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import UIKit

class TodayDetailVC: ERViewController {
    private let viewModel: TodayDetailViewModel

    init(viewModel: TodayDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension TodayDetailVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadNewItems()
    }
}
