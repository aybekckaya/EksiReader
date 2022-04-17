//
//  NetworkingDataResponse.swift
//  EksiReader
//
//  Created by aybek can kaya on 17.04.2022.
//

import Foundation

class NetworkingDataResponse: NetworkingResponseProvider {

    private var _successCallback: NetworkingResponseSuccessCallback<Data>?

    func onSuccess(_ callback: @escaping NetworkingResponseSuccessCallback<Data>) {
        self._successCallback = callback
    }

    func handleResponseData(_ responseData: Data) -> NetworkingError? {
        self._successCallback?(responseData)
        return nil 
    }
}
