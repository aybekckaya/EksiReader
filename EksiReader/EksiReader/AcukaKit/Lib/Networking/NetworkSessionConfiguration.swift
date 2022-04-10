//
//  NetworkSessionConfiguration.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

struct NetworkSessionConfiguration {
   //  let cache

    let timeout: TimeInterval


}


extension NetworkSessionConfiguration {
    static func defaultConfiguration() -> NetworkSessionConfiguration {
        return .init(timeout: 10)
    }
}
