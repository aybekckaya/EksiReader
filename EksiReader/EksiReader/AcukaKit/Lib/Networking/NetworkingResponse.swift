//
//  NetworkingResponse.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 31.03.2022.
//

import Foundation

typealias NetworkingResponseCallback = (NetworkingResponse) -> Void
typealias NetworkingResponseErrorCallback = (NetworkingError) -> Void
typealias NetworkingResponseSuccessCallback<T> = (T) -> Void
typealias NetworkingResponseOnCompletedCallback = (NetworkingCore) -> Void

protocol NetworkingResponseProvider {
   // func handleResponse(_ res: NetworkingResponse)
    func handleResponseData(_ responseData: Data) -> NetworkingError?
}

//protocol NetworkingErrorPresentable {
//    var errorCallback: NetworkingResponseErrorCallback? { get }
//    func onError(_ callback: NetworkingResponseErrorCallback?)
//}

// MARK: - NetworkingResponse
class NetworkingResponse {
    private var _data: Data?
    private var _error: NetworkingError?
    private var _response: URLResponse?

    var error: NetworkingError? {
        return errorModel()
    }

    var data: Data? {
        guard errorModel() == nil else { return nil }
        return _data
    }

    var isSuccess: Bool {
        guard errorModel() == nil && _data != nil else { return false }
        return true
    }

    init(data: Data?, error: Error?, response: URLResponse?) {
        self._data = data
        self._error = nil
        self._response = response
        if let error = error {
            self._error = .builtInError(error: error)
        }
    }

    init(error: NetworkingError) {
       self._data = nil
       self._response = nil
       self._error = error
   }

    private func errorModel() -> NetworkingError? {
        if let _error = _error { return _error }
        guard let _response = _response else { return .responseModelIsNull }
        guard let httpResponse = _response as? HTTPURLResponse else { return .responseCannotConvertedToHTTPResponse(response: _response) }
        guard (200...299).contains(httpResponse.statusCode) else { return .responseCodeIsNotSatisfied(response: httpResponse) }
        guard let _ = _data else { return .responseDataIsNil }
        return nil
    }
}
