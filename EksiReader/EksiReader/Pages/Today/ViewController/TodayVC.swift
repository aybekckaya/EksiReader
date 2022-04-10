//
//  TodayVC.swift
//  EksiReader
//
//  Created by aybek can kaya on 5.04.2022.
//

import Foundation
import UIKit

class TodayVC: ERViewController {
    private let viewModel: TodayViewModel

    init(viewModel: TodayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Lifecycle
extension TodayVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
