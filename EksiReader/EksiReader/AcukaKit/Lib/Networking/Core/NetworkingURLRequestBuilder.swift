//
//  NetworkingURLRequestBuilder.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

class NetworkingURLRequestBuilder {
    private let request: NetworkRequest
    private let sessionConfiguration: NetworkSessionConfiguration

    init(request: NetworkRequest, sessionConfiguration: NetworkSessionConfiguration) {
        self.request = request
        self.sessionConfiguration = sessionConfiguration
    }

    func build() -> (error: NetworkingError?, request: URLRequest?) {
        guard let url = URL(string: request.url) else {
            return (error: .urlCannotBeFormed, request: nil)
        }
        let req = urlRequest(with: url)
        return (error: nil, request: req)
    }
}

// MARK: - URL Request Builder
extension NetworkingURLRequestBuilder {
    private func urlRequest(with url: URL) -> URLRequest {
        let requestData = requestData()
        let url = buildURL(from: url)

        return URLRequest(url: url)
            .cachePolicy(.reloadIgnoringCacheData)
            .timeoutInterval(10)
            .headers(request.headers)
            .httpBody(requestData)
            .httpMethod(request.method.stringify)
    }
}

// MARK: - URL Builder
extension NetworkingURLRequestBuilder {
    private func buildURL(from url: URL) -> URL {
        guard
            self.request.method == .get,
            let reqModelStr = request.requestData.toString()
        else { return url }
        var reqModelsArr: [String] = reqModelStr.components(separatedBy: "&")
        let urlString = url.absoluteString
        var strComponents = urlString.components(separatedBy: "?")
        let leftPart = strComponents.first!
        var rightPart = ""
        if strComponents.count > 1 {
            let _ = strComponents.remove(at: 0)
            rightPart = strComponents.joined(separator: "")
        }
        if rightPart != "" {
            reqModelsArr.insert(rightPart, at: 0)
        }
        let parametersStr = "?" + reqModelsArr.joined(separator: "&")
        let fullURLString = leftPart + parametersStr
        return URL(string: fullURLString) ?? url 
    }
}

// MARK: - Request Data
extension NetworkingURLRequestBuilder {
    private func requestData() -> Data? {
        guard self.request.method != .get else {
            return nil
        }
        if let requestData = request.requestData {
            return requestData
        }
        return nil
    }
}

// MARK: - URLRequest + Extension
private extension URLRequest {

    @discardableResult
    func cachePolicy(_ value: URLRequest.CachePolicy) -> URLRequest {
        var mutableSelf = self
        mutableSelf.cachePolicy = value
        return mutableSelf
    }

    @discardableResult
    func timeoutInterval(_ value: TimeInterval) -> URLRequest {
        var mutableSelf = self
        mutableSelf.timeoutInterval = value
        return mutableSelf
    }

    @discardableResult
    func httpMethod(_ value: String) -> URLRequest {
        var mutableSelf = self
        mutableSelf.httpMethod = value
        return mutableSelf
    }

    @discardableResult
    func httpBody(_ data: Data?) -> URLRequest {
        var mutableSelf = self
        mutableSelf.httpBody = data
        return mutableSelf
    }

    @discardableResult
    func headers(_ value: [NetworkingRequestHeader]?) -> URLRequest {
        guard let value = value else {
            return self
        }
        var mutableSelf = self
        value.forEach {
            mutableSelf.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        return mutableSelf
    }
}

