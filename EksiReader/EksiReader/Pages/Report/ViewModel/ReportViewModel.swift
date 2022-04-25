//
//  ReportViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation


class ReportViewModel {
    enum Change {
        case presentation(presentation: ReportPresentation)
    }

    private let dataController: ReportDataController
    private let router: ReportRouter

    var change: ((Change) -> Void)?

    init(dataController: ReportDataController, router: ReportRouter) {
        self.dataController = dataController
        self.router = router 
    }

    func initialize() {
        let author = dataController.getAuthor()
        let presentation = ReportPresentation(author: author, isBlocked: dataController.isAuthorBlocked)
        change?(.presentation(presentation: presentation))
    }

    func toggleAuthorBlockState() {
        dataController.toggleAuthorBlockState()
        router.dismissReportViewController()
    }

}

