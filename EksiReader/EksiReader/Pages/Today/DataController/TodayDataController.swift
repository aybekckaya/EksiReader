//
//  TodayDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

class TodayDataController: PagableDataController {

    typealias T = TodaysEntry
    typealias Response = TodaysResponse

    var entries: [TodaysEntry] = []
    var currentPage: Int = 0
    var totalPageCount: Int = Int.max

    var endpoint: EREndpoint {
        EREndpoint.today(page: currentPage)
    }

    init() {

    }
}

