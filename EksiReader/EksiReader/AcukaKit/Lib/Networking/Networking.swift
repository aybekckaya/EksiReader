//
//  Networking.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 7.03.2022.
//

import Foundation

class NetworkingCore {
    let identifier: String
    private var sessionConfiguration: NetworkSessionConfiguration = .defaultConfiguration()
    private var request: NetworkRequest?
    private var session: NetworkingSession?
    private var errorCallback: NetworkingResponseErrorCallback?

    private var responseProviders: [NetworkingResponseProvider] = []
    private var logProviders: [NetworkingLogProvider] = []
    private var onCompletedCallback: NetworkingResponseOnCompletedCallback?

    init(identifier: String) {
        self.identifier = identifier
    }
}

// MARK: - Public
extension NetworkingCore {
    @discardableResult
    func onCompleted(_ callback: @escaping NetworkingResponseOnCompletedCallback) -> NetworkingCore {
        self.onCompletedCallback = callback
        return self
    }

    @discardableResult
    func consoleLogProvider(_ enabledTypes: [NetworkingLogType]) -> NetworkingCore {
        let consoleLogger = NetworkingConsoleLogger(enabledLogTypes: enabledTypes)
        logProviders.append(consoleLogger)
        return self
    }

    @discardableResult
    func sessionConfiguration(_ configuration: NetworkSessionConfiguration) -> NetworkingCore {
        self.sessionConfiguration = configuration
        return self
    }

    @discardableResult
    func request(_ request: NetworkRequest) -> NetworkingCore {
        self.request = request
        return self
    }

    @discardableResult
    func onError(_ errorCallback: @escaping NetworkingResponseErrorCallback) -> NetworkingCore {
        self.errorCallback = errorCallback
        return self
    }

    @discardableResult
    func onDecodableResponse<T: Decodable>(of type: T.Type,
                                           callback: @escaping NetworkingResponseSuccessCallback<T>) -> NetworkingCore {
        let provider = NetworkingJsonResponse<T>()
        provider.onSuccess(callback)
        self.responseProviders.append(provider)
        return self
    }

    @discardableResult
    func call() -> NetworkingCore {
        guard let request = self.request else {
            return self
        }
        let validationResult = NetworkingValidator.validateRequest(request)
        guard validationResult.validationSuccess == true else {
            validationResult.errors.forEach {
                self.errorCallback?($0)
            }
            return self
        }

        self.session = NetworkingSession(request: request,
                                         sessionConfiguration: sessionConfiguration,
                                         responseProviders: responseProviders,
                                         errorCallback: self.errorCallback,
                                         logProviders: logProviders)
        session?.onCompleted {
            self.onCompletedCallback?(self)
        }
        self.session?.call()
        return self
    }

    @discardableResult
    func cancel() -> NetworkingCore {
        guard let session = self.session else { return self }
        session.cancel()
        return self
    }
}







