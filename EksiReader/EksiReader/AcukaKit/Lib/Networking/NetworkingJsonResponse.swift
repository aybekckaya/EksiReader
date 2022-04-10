//
//  NetworkingJsonResponse.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

// MARK: - NetworkingJSONResponse
class NetworkingJsonResponse<T: Decodable>: NetworkingResponseProvider, NetworkingErrorPresentable {

    var errorCallback: NetworkingResponseErrorCallback? {
        _errorCallback
    }

    private var _successCallback: NetworkingResponseSuccessCallback<T>?
    private var _errorCallback: NetworkingResponseErrorCallback?

    func handleResponse(_ res: NetworkingResponse) {
        if let networkingError = res.error,
            let errorCallback = _errorCallback {
            errorCallback(networkingError)
            return
        }

        guard let data = res.data else {
            if let errorCallback = _errorCallback {
                errorCallback(.responseDataIsNil)
            }
            return
        }

        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            if let successCallback = _successCallback {
                successCallback(model)
            }
        } catch let error {
            if let errorCallback = _errorCallback {
                errorCallback(.builtInError(error: error))
            }
        }
    }

    func onSuccess(_ callback: @escaping NetworkingResponseSuccessCallback<T>) {
        self._successCallback = callback
    }

    func onError(_ callback: NetworkingResponseErrorCallback?) {
        self._errorCallback = callback
    }

}
