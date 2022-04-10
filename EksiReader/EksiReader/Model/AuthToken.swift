//
//  AuthToken.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

struct AuthToken: Codable {
    let token: String?
    let expireTimeInterval: Int?
}

extension AuthToken {
    init?(authTokenResponse: AuthTokenResponse?) {
        guard let authTokenResponse = authTokenResponse,
              let token = authTokenResponse.accessToken,
              let expireTimeInterval = Int(authTokenResponse.expiresIn ?? "0")
        else {
            return nil
        }
        self.token = token
        self.expireTimeInterval = expireTimeInterval + Int(Date().timeIntervalSince1970)
    }
}

extension AuthToken {
    func isExpired() -> Bool {
        guard let expireTimeInterval = expireTimeInterval else { return true }
        let currentTimeInterval = Int(Date().timeIntervalSince1970)
        let isExpired = currentTimeInterval >= expireTimeInterval
        return isExpired
    }
}
