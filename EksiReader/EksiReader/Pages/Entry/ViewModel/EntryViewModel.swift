//
//  EntryViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 17.04.2022.
//

import Foundation

class EntryViewModel {

    private let dataController: EntryDataController
    private let router: EntryRouter

    init(dataController: EntryDataController, router: EntryRouter ) {
        self.dataController = dataController
        self.router = router
    }
}
