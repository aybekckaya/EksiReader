//
//  NetworkingConsoleLogger.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

class NetworkingConsoleLogger: NetworkingLogProvider {


    var enabledLogTypes: [NetworkingLogType] {
        _enabledLogTypes
    }

    private var _enabledLogTypes: [NetworkingLogType] = []

    required init(enabledLogTypes: [NetworkingLogType]) {
        self._enabledLogTypes = enabledLogTypes
    }


    func logRequest(_ request: NetworkRequest?, urlRequest: URLRequest?) {
        guard _enabledLogTypes.contains(.request) else { return }
        guard let req = request, let urlRequest = urlRequest else {
            NSLog("Request: nil")
            return
        }

        let headerVal = urlRequest.allHTTPHeaderFields?.map { (key, value) -> String in
            return "\(key) : \(value)"
        }.joined(separator: "\n") ?? "No Header"

        let bodyString = req.requestData.toString() ?? "nil"

        var text = "\n\nRequest \n"
        text += "\n"
        text += "URL: \n\(req.url)"
        text += "\n"
        text += "\n"
        text += "Method: \(req.method.stringify)"
        text += "\n"
        text += "\n"
        text += "Headers:"
        text += "\n"
        text += headerVal
        text += "\n"
        text += "\n"
        text += "Request Data: \n"
        text += bodyString

        text += "\n"
        text += "\n"

        NSLog(text)
    }

    func logResponse(_ response: NetworkResponseModel?) {
        guard _enabledLogTypes.contains(.response) else { return }
        guard let model = response else {
            NSLog("Response: nil")
            return
        }

        var text: String = ""
        text += "\n"
        text += "Response: "
        text += "\n"
        text += "Text"
        text += "\n"
        let dataText = model._data.toString()
        text += dataText ?? "nil"

        NSLog(text)
    }



}
