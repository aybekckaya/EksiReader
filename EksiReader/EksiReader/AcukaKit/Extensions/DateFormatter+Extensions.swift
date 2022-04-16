//
//  DateFormatter+Extensions.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation
import UIKit

extension DateFormatter {
    // 2021-08-04T23:06:42.157
    static var erStringToDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()

    static var erDateToStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }()
}


extension String {
    func toDate(with formatter: DateFormatter) -> Date? {
        return formatter.date(from: self)
    }
}

extension Date {
    func toString(with formatter: DateFormatter) -> String {
        return formatter.string(from: self) ?? ""
    }
}
