//
//  NetworkingRequestMethod.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 31.03.2022.
//

import Foundation

// MARK: NetworkingNewRequestMethod - Enum
enum NetworkingRequestMethod {
    case get
    case put
    case post
    case delete

    var stringify:String {
        switch self {
            case .get: return "GET"
            case .put: return "PUT"
            case .delete: return "DELETE"
            case .post: return "POST"
        }
    }
}
