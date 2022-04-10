//
//  NetworkingError.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 31.03.2022.
//

import Foundation

// MARK: Network Error - Enum
enum NetworkingError {
    case objectDeallocated
    case urlCannotBeFormed
    case responseModelIsNull
    case responseCannotConvertedToHTTPResponse(response: URLResponse)
    case responseCodeIsNotSatisfied(response: HTTPURLResponse)
    case mimeTypeIsNotSatisfied
    case responseDataIsNil
    case responseDataCannotBeConvertedToJSON
    case urlRequestCannotBeFormed
    case downloadedURLIsNull
    case builtInError(error: Error)
}

// MARK: - NSError
extension NetworkingError {
    var error:NSError {
        switch self {
        case .responseModelIsNull:
            return NSError(domain: "Network-Error", code: 10009, userInfo: ["desc" : "Response Model is Null"])
        case .responseCannotConvertedToHTTPResponse(let response):
            return  NSError(domain: "Network-Error",
                            code: 10008,
                            userInfo: ["desc" : "Response Cannot Converted to HttpResponse", "object": response])
        case .objectDeallocated:
            return NSError(domain: "Network-Error", code: 10007, userInfo: ["desc" : "Object deallocated before use"])
        case .urlCannotBeFormed:
            return NSError(domain: "Network-Error", code: 10000, userInfo: ["desc" : "URL Cannot Be Formed"])
        case .responseCodeIsNotSatisfied(let response):
            return NSError(domain: "Network-Error",
                           code: 10001,
                           userInfo: ["desc" : "Response Code is not satisfied", "object": response])
        case .mimeTypeIsNotSatisfied:
            return NSError(domain: "Network-Error", code: 10002, userInfo: ["desc" : "Mime type not satisfied"])
        case .responseDataIsNil:
            return NSError(domain: "Network-Error", code: 10003, userInfo: ["desc" : "Response Data is Null"])
        case .responseDataCannotBeConvertedToJSON:
            return NSError(domain: "Network-Error", code: 10004, userInfo: ["desc" : "Response data cannot be converted to json"])
        case .downloadedURLIsNull:
            return NSError(domain: "Network-Error", code: 10005, userInfo: ["desc" : "Downloaded URL is NULL"])
        case .urlRequestCannotBeFormed:
            return NSError(domain: "Network-Error", code: 10005, userInfo: ["desc" : "URL request cannot be formed"])
        case .builtInError(let error):
            return NSError(domain: "Network-Error", code: 10006, userInfo: ["desc" : error.localizedDescription])
        }
    }

}
