//
//  NetworkingSession.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

class NetworkingSession {
    private let request: NetworkRequest
    private let sessionConfiguration: NetworkSessionConfiguration
    private let responseProviders: [NetworkingResponseProvider]
    private let errorCallback: NetworkingResponseErrorCallback?
    private let logProviders: [NetworkingLogProvider]

    private var onCompletedCallback: (() -> Void)?
    private var dataTask: URLSessionDataTask?

    init (request: NetworkRequest,
          sessionConfiguration: NetworkSessionConfiguration,
          responseProviders: [NetworkingResponseProvider],
          errorCallback: NetworkingResponseErrorCallback?,
          logProviders: [NetworkingLogProvider]) {
        self.request = request
        self.sessionConfiguration = sessionConfiguration
        self.responseProviders = responseProviders
        self.errorCallback = errorCallback
        self.logProviders = logProviders
    }
}

// MARK: - Public
extension NetworkingSession {
    func call() {
        _call()
    }

    func cancel() {
        _cancel()
    }

    func onCompleted(_ callback: @escaping () -> Void) {
        self.onCompletedCallback = callback
    }
}


// MARK: - Call Session
extension NetworkingSession {
    private func _call() {
        let requestBuilder = NetworkingURLRequestBuilder(request: request,
                                                         sessionConfiguration: sessionConfiguration)
        let builtRequest = requestBuilder.build()

        guard let urlRequest = builtRequest.request else {
            if let error = builtRequest.error {
                self.errorCallback?(error)
            }
            self.onCompletedCallback?()
            return
        }

        logRequest(request, urlRequest: urlRequest)
        let responseProviders = self.responseProviders
        let logProviders = self.logProviders
        let onCompletedCallback = self.onCompletedCallback
        self.dataTask = urlRequest
            .sessionDataTask { [weak self] response in
                guard let _ = self else {
                    let response = NetworkResponseModel(error: .objectDeallocated)
                    let handler = NetworkDataHandler(response: response,
                                                     responseProviders: responseProviders,
                                                     logProviders: logProviders)
                    let _ = handler.handle()
                    onCompletedCallback?()
                    return
                }

                let handler = NetworkDataHandler(response: response,
                                                 responseProviders: responseProviders,
                                                 logProviders: logProviders)
                if let error = handler.handle() {
                    self?.errorCallback?(error)
                }
                self?.dataTask = nil
                onCompletedCallback?()
            }
        self.dataTask?.resume()
    }
}

// MARK: - Loggers
extension NetworkingSession {
    private func logRequest(_ req: NetworkRequest, urlRequest: URLRequest) {
        logProviders.forEach {
            $0.logRequest(req, urlRequest: urlRequest)
        }
    }
}

// MARK: - Cancel Session
extension NetworkingSession {
    private func _cancel() {
        guard let dataTask = dataTask else { return }
        dataTask.cancel()
    }
}

// MARK: - Request Creator
extension NetworkingSession {

}

private extension URLRequest {
    func sessionDataTask(_ callback: @escaping NetworkingResponseCallback) -> URLSessionDataTask {
        return URLSession
            .shared
            .dataTask(with: self) { data, response, error in
                let response = NetworkResponseModel(data: data,
                                                  error: error,
                                                  response: response)
                callback(response)
            }
    }

}


// MARK: - { Class } Data Handler
private class NetworkDataHandler {
    private let response: NetworkResponseModel
    private let providers: [NetworkingResponseProvider]
    private let logProviders: [NetworkingLogProvider]

    init(response: NetworkResponseModel,
         responseProviders: [NetworkingResponseProvider],
         logProviders: [NetworkingLogProvider] ) {
        self.response = response
        self.providers = responseProviders
        self.logProviders = logProviders
    }

    func handle() -> NetworkingError? {
        self.logResponse()
        var error: NetworkingError? = nil
        self.providers.forEach {
            error = self.handleResponse(of: $0)
        }
        return error
    }

    private func handleResponse(of provider: NetworkingResponseProvider) -> NetworkingError?  {
        if let error = response.error {
            return error
        }
        guard let data = response.data else {
            return NetworkingError.responseDataIsNil
        }
        return provider.handleResponseData(data)
    }

    private func logResponse() {
        logProviders.forEach { provider in
            provider.logResponse(response)
        }
    }
}

