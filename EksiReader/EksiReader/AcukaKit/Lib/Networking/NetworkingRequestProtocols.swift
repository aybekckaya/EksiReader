//
//  NetworkingRequestProtocols.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

protocol NetworkRequest {
    var url: String { get }
    var method: NetworkingRequestMethod { get }
    var requestData: Data? { get }
   // var requestModel: Encodable? { get }
    var headers: [NetworkingRequestHeader]? { get }

    init(url: String, method: NetworkingRequestMethod)
}

extension NetworkRequest {
    func convertJsonModelToDictionary<T: Encodable>(_ model: T?) -> [String: Any?]? {
        guard
            let model = model,
            let jsonData = try? JSONEncoder().encode(model),
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: [])
        else {
            return nil
        }
        return dictionary as? [String: Any?]
    }

    func encodeParameters(dictionary: [String: Any?]?) -> String? {
        guard let dictionary = dictionary else {
            return nil
        }

        let encoded = dictionary
            .compactMapValues { $0 }
            .map { (key, value) -> String in
                if let strValue = value as? String {
                    return "\(key)=\(strValue.percentEscapedString())"
                }
                return "\(key)=\(value)"
            }.joined(separator: "&")

        return encoded
    }
}

// MARK: - Percent Escaped String
fileprivate extension String {
    func percentEscapedString() -> String {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._* ")
        let set = characterSet as CharacterSet

        guard
            let percentEncoding = self.addingPercentEncoding(withAllowedCharacters: set)
        else {
            return self
        }
        return percentEncoding.replacingOccurrences(of: " ", with: "+")
    }
}
