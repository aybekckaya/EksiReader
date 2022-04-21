//
//  NetworkingDebugger.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 31.03.2022.
//

import Foundation

enum NetworkingLogType {
    case request
    case response
}

protocol NetworkingLogProvider {
    var enabledLogTypes: [NetworkingLogType] { get }

    init(enabledLogTypes: [NetworkingLogType])
    func logRequest(_ request: NetworkRequest?, urlRequest: URLRequest?)
    func logResponse(_ response: NetworkResponseModel?)
}

// MARK: - Data Extensions
extension Optional where Wrapped == Data {
    func toJsonObject() -> [String: Any]? {
        guard let data = self else { return nil }
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as?  [String: Any]
        return jsonObject
    }

    func toString() -> String? {
        guard let data = self else {
            return nil
        }
        let str = String(data: data, encoding: .utf8)
        return str
    }
}


//
//enum NetworkDebuggerElement {
//    case request
//    case response
//}
//
////// MARK: - NetworkDebuggerElement + Stringify
////extension NetworkDebuggerElement {
////    func stringify(_ value: Any?) -> String? {
////        return nil
////    }
////}
//
//class NetworkDebugger {
//    private let debugElements: [NetworkDebuggerElement]
//
//
//    init(elements: [NetworkDebuggerElement]) {
//        self.debugElements = elements
//    }
//
//    func log(_ value: Any?, element: NetworkDebuggerElement) {
//
//    }
//
//}
//
//
//// MARK: - Data Extensions
//extension Optional where Wrapped == Data {
//    func toJsonObject() -> [String: Any]? {
//        guard let data = self else { return nil }
//        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as?  [String: Any]
//        return jsonObject
//    }
//
//    func toString() -> String? {
//        guard let data = self else {
//            return nil
//        }
//        let str = String(data: data, encoding: .utf8)
//        return str
//    }
//}


