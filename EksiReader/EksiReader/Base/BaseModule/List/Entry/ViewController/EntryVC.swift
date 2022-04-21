//
//  EntryVC.swift
//  EksiReader
//
//  Created by aybek can kaya on 17.04.2022.
//

import Foundation
import UIKit

class EntryVC: ERViewController {
    private let viewModel: EntryViewModel

    init(viewModel: EntryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Lifecycle
extension EntryVC {
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
