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

    private var reachability = try? Reachability()
    private var authToken: AuthToken?
    private var networkers: [NetworkingCore] = []
}

// MARK: - Public
extension EksiCloud {
    func call<T: Decodable>(endpoint: EREndpoint, responseType: T.Type, callback: @escaping EksiCloudResponseCallback<T>) {

        // if not reachable , no need to call auth token , because we will be reading
        // from cached files
        guard isNetworkReachable() else {
            self._call(endpoint: endpoint, responseType: responseType, callback: callback)
            return
        }

        callForAuthTokenIfNeeded {
            self._call(endpoint: endpoint, responseType: responseType, callback: callback)
        }
    }
}

// MARK: - Reachablity
extension EksiCloud {
    private func isNetworkReachable() -> Bool {
        guard let reachability = reachability else {
            self.reachability = try? Reachability()
            return true
        }

        return reachability.connection != .unavailable
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
            //self.authToken = AuthToken(authTokenResponse: response)
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
        guard let request = self.request(endpoint: endpoint) else {
            callback(nil)
            return
        }

        let networker = NetworkingCore(identifier: UUID().uuidString)
        self.networkers.append(networker)

        networker
            .consoleLogProvider([.request, .response])
            .request(request)
            .onCompleted{ [weak self] networker in
                self?.removeNetworker(networker: networker)
            }.onDecodableResponse(of: responseType, callback: callback)
            .onError { error in
                NSLog("Error: \(error)")
                callback(nil)
            }.call()
    }

    private func request(endpoint: EREndpoint) -> NetworkingDataRequest? {
        var request: NetworkingDataRequest?
        if case .authorizationToken = endpoint {
            guard let _request = endpoint.request() else {
                return nil
            }
            request = _request
        } else {
            guard let token =  EksiCloud.shared.authToken, let accessToken = token.token else {
                return nil
            }
            guard let _request = endpoint.request() else {
                return nil
            }

            var currentHeaders = _request.headers
            currentHeaders?.append(.bearerToken(accessToken))
            _request.headers(currentHeaders ?? [])
            request = _request
        }
        return request
    }

    private func removeNetworker(networker: NetworkingCore) {
        let newNetworkers = self.networkers
            .filter { $0.identifier != networker.identifier }
        self.networkers = newNetworkers
    }
}
