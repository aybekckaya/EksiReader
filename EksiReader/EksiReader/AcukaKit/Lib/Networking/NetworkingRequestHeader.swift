//
//  NetworkingRequestHeader.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 31.03.2022.
//

import Foundation

struct NetworkingRequestHeader {
    let key: String
    let value: String?
}

extension NetworkingRequestHeader {
    static func bearerToken(_ token: String) -> NetworkingRequestHeader {
        return .init(key: "Authorization", value: "Bearer \(token)")
    }

    static func contentTypeValue(_ value: NetworkingRequestHeader.ContentType) -> NetworkingRequestHeader {
        return .init(key: "Content-Type", value: value.value)
    }
}

extension NetworkingRequestHeader {
    enum ContentType {
        case json
        case urlEncodedForm

        var value: String {
            switch self {
            case .json:
                return "application/json; charset=utf-8"
            case .urlEncodedForm:
                return "application/x-www-form-urlencoded"
            }
        }
    }
}
