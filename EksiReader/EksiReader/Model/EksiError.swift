//
//  EksiError.swift
//  EksiReader
//
//  Created by aybek can kaya on 11.04.2022.
//

import Foundation

enum EksiError: Error {
    case selfIsDeallocated
    case networkError(error: NetworkingError)
    case todaysResponseIsNil
}
