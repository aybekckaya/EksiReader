//
//  TodayDetailRouter.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import UIKit

class TopicRouter {

    func showShareSheet(eksiLink: String) {
        let activityViewController = UIActivityViewController(activityItems: [eksiLink], applicationActivities: nil)
        ERNavUtility.showActivityViewController(activityViewController)
    }

    func routeToEntry(entryId: Int) {
        let router = EntryRouter()
        let dataController = EntryDataController(entryId: entryId)
        let viewModel = EntryViewModel(dataController: dataController, router: router)
        let viewController = EntryVC(viewModel: viewModel)
        ERNavUtility.push(viewController: viewController)
    }

    func showReportSheet(author: Author) {
        let dataController = ReportDataController(author: author)
        let router = ReportRouter()
        let viewModel = ReportViewModel(dataController: dataController, router: router)
        let viewController = ReportViewController(viewModel: viewModel)
        ERNavUtility.showBottomSheetViewController(viewController)
    }

    func routeToAuthorInfo(authorNick: String) {
        // https://eksisozluk.com/biri/cobainscream
        guard let url = URL(string: "https://eksisozluk.com/biri/\(authorNick)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

