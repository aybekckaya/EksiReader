//
//  EksiResponses.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

// MARK: - AuthTokenResponse
struct AuthTokenResponse: Decodable {
    let success: Bool
    let message: String?
    let accessToken: String?
    let expiresIn: String?

    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case message = "Message"
        case accessToken = "access_token"
        case data = "Data"
        case expiresIn = "expires_in"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.accessToken = try dataContainer.decodeIfPresent(String.self, forKey: .accessToken)
        self.expiresIn = try dataContainer.decodeIfPresent(String.self, forKey: .expiresIn) ?? "0"
    }
}

// MARK: - Todays Response
struct TodaysEntry: Decodable {
    let fullCount: Int
    let title: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case fullCount = "FullCount"
        case title = "Title"
        case id = "TopicId"
    }
}

struct TodaysResponse: Decodable {
    let entries: [TodaysEntry]
    let pageCount: Int
    let pageIndex: Int

    enum CodingKeys: String, CodingKey {
        case entries = "Topics"
        case data = "Data"
        case pageCount = "PageCount"
        case pageIndex = "PageIndex"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.pageCount = try dataContainer.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
        self.pageIndex = try dataContainer.decodeIfPresent(Int.self, forKey: .pageIndex) ?? 0
        self.entries = try dataContainer.decode([TodaysEntry].self, forKey: .entries)
       // let entriesContainer = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .entries)
    }
}

