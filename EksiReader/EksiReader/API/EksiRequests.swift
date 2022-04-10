//
//  EksiRequests.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

// MARK: - TodaysRequest
struct TodaysRequest: Encodable {
    let page: Int

    enum CodingKeys: String, CodingKey {
        case page = "p"
    }
}

// MARK: - AuthTokenTokenRequest
struct AuthTokenTokenRequest: Encodable {
    let Platform: String
    let Version: String
    let Build: String
    let ApiSecret: String
    let ClientSecret: String
    let ClientUniqueId: String

    enum CodingKeys: String, CodingKey {
        case Platform = "Platform"
        case Version = "Version"
        case Build = "Build"
        case ApiSecret = "Api-Secret"
        case ClientSecret = "Client-Secret"
        case ClientUniqueId = "ClientUniqueId"
    }
}

