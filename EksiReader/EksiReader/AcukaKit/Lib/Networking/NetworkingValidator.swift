//
//  NetworkingValidator.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

class NetworkingValidator {
    static func validateRequest(_ request: NetworkRequest) -> (validationSuccess: Bool, errors: [NetworkingError]) {
        var errors: [NetworkingError] = []
        if URL(string: request.url) == nil {
            errors.append(.urlCannotBeFormed)
        }

        return (validationSuccess: errors.isEmpty, errors: errors)
    }
}
