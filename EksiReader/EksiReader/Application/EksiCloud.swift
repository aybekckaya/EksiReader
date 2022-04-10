//
//  EksiCloud.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

typealias EksiCloudResponseCallback<T: Decodable> = (T?) -> Void

class EksiCloud {
    static let shared = EksiCloud()

    private(set) var authToken: AuthToken?
    private var networker: NetworkingCore?
}

// MARK: - Public
extension EksiCloud {
    func call<T: Decodable>(endpoint: EREndpoint, responseType: T.Type, callback: @escaping EksiCloudResponseCallback<T>) {
        callForAuthTokenIfNeeded {
            self._call(endpoint: endpoint, responseType: responseType, callback: callback)
        }
    }
}

// MARK: - AuthToken Request
extension EksiCloud {
    private func callForAuthTokenIfNeeded(callback: @escaping () -> Void) {
        guard self.shouldCallTokenRequest() else {
            callback()
            return
        }
        _call(endpoint: .authorizationToken, responseType: AuthTokenResponse.self) { response in
            EksiCloud.shared.authToken = AuthToken(authTokenResponse: response)
            callback()
        }
    }

    private func shouldCallTokenRequest() -> Bool {
        guard let authToken = authToken,
              let _ = authToken.token,
              let _ = authToken.expireTimeInterval,
              authToken.isExpired() == false else { return true }
        return false
    }
}

// MARK: - Call Request
extension EksiCloud {
    private func _call<T: Decodable>(endpoint: EREndpoint,
                                     responseType: T.Type,
                                     callback: @escaping EksiCloudResponseCallback<T>) {

        if case .authorizationToken = endpoint {

        } else {
            guard let _ =  EksiCloud.shared.authToken else {
                callback(nil)
                return
            }
        }

        guard let request = endpoint.request() else {
            callback(nil)
            return
        }

        let networker = NetworkingCore()
        self.networker = networker

        networker
            .request(request)
            .onDecodableResponse(of: responseType, callback: callback)
            .onError { error in
                NSLog("Error: \(error)")
                callback(nil)
            }.call()
    }
}
