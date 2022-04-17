//
//  NetworkingJsonResponse.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

// MARK: - NetworkingJSONResponse
class NetworkingJsonResponse<T: Decodable>: NetworkingResponseProvider {

    private var _successCallback: NetworkingResponseSuccessCallback<T>?

    func onSuccess(_ callback: @escaping NetworkingResponseSuccessCallback<T>) {
        self._successCallback = callback
    }

    func handleResponseData(_ responseData: Data) -> NetworkingError? {
        do {
            let model = try JSONDecoder().decode(T.self, from: responseData)
            if let successCallback = _successCallback {
                successCallback(model)
            }
        } catch let error {
            return .builtInError(error: error)
        }
        return nil
    }

}
