//
//  NetworkingDataRequest.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation


class NetworkingDataRequest: NetworkRequest {

    var url: String { _url }
    var method: NetworkingRequestMethod { _method }
    var requestData: Data? { _requestData }
    var headers: [NetworkingRequestHeader]? { _headers }
   /// var requestModel: RequestModellable? { _requestModel }

    private let _method: NetworkingRequestMethod
    private let _url: String
    private var _requestData: Data?
    private var _headers: [NetworkingRequestHeader]?
    //private var _requestModel: RequestModellable?

    required init(url: String, method: NetworkingRequestMethod) {
        self._method = method
        self._url = url
    }
}

// MARK: - Public
extension NetworkingDataRequest {
    @discardableResult
    func requestData(_ data: Data) -> NetworkingDataRequest {
        self._requestData = data
        return self
    }

    @discardableResult
    func headers(_ value: [NetworkingRequestHeader]) -> NetworkingDataRequest {
        self._headers = value 
        return self
    }

    @discardableResult
    func requestModel<T: Encodable>(_ value: T?) -> NetworkingDataRequest {
        switch self.method {
        case .get:
            self._requestData = requestDataGet(value)
        case .post:
            self._requestData = requestDataPost(value)
        default:
            return self
        }
        if
            let dct = convertJsonModelToDictionary(value),
            let str = encodeParameters(dictionary: dct) {
            self._requestData = str.data(using: .utf8)
        }
        return self
    }

    private func requestDataGet<T: Encodable>(_ value: T?) -> Data? {
        guard
            let dct = convertJsonModelToDictionary(value),
            let str = encodeParameters(dictionary: dct)
        else {
            return nil
        }

        return str.data(using: .utf8)
    }

    private func requestDataPost<T: Encodable>(_ value: T?) -> Data? {
        guard
            let dct = convertJsonModelToDictionary(value),
            let str = encodeParameters(dictionary: dct)
        else {
            return nil
        }
        return str.data(using: .utf8)
    }

}
