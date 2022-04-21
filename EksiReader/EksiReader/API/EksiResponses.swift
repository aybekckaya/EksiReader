//
//  EksiResponses.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation


// MARK: - AuthTokenResponse
struct AuthTokenResponse: ERBaseResponse {
    var success: Bool?
    var message: String?
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
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.accessToken = try dataContainer.decodeIfPresent(String.self, forKey: .accessToken)
        self.expiresIn = try dataContainer.decodeIfPresent(String.self, forKey: .expiresIn) ?? "0"
    }
}

// MARK: - Todays Response
struct TopicListEntry: Decodable {
    let fullCount: Int
    let title: String
    let id: Int
    let day: String?
    let matchedCount: Int

    enum CodingKeys: String, CodingKey {
        case fullCount = "FullCount"
        case title = "Title"
        case id = "TopicId"
        case day = "Day"
        case matchedCount = "MatchedCount"
    }
}

struct TodaysResponse: ERBaseResponse, ERPagable {
    typealias T = TopicListEntry
    var success: Bool?
    var message: String?
    var entries: [T]
    var pageCount: Int
    var pageIndex: Int

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case entries = "Topics"
        case data = "Data"
        case pageCount = "PageCount"
        case pageIndex = "PageIndex"
        case success = "Success"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.pageCount = try dataContainer.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
        self.pageIndex = try dataContainer.decodeIfPresent(Int.self, forKey: .pageIndex) ?? 0
        self.entries = try dataContainer.decode([TopicListEntry].self, forKey: .entries)
       // let entriesContainer = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .entries)
    }
}

// MARK: - Today Topic Response
struct TopicEntry: Decodable {
    let author: EksiAuthor?
    let id: Int
    let content: String
    let favoriteCount: Int
    let created: String
    let lastUpdated: String?
    let commentCount: Int
    let avatarUrl: String?
    let isSponsored: Bool
    let isVerifiedAccount: Bool

    enum CodingKeys: String, CodingKey {
        case author = "Author"
        case id = "Id"
        case content = "Content"
        case favoriteCount = "FavoriteCount"
        case created = "Created"
        case lastUpdated = "LastUpdated"
        case commentCount = "CommentCount"
        case avatarUrl = "AvatarUrl"
        case isSponsored = "IsSponsored"
        case isVerifiedAccount = "IsVerifiedAccount"
    }
}

struct EksiAuthor: Decodable {
    let nick: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case nick = "Nick"
        case id = "Id"
    }
}

struct TodayTopicResponse: ERBaseResponse, ERPagable, ERResponseTitle {
    typealias T = TopicEntry
    var success: Bool?
    var message: String?
    var entries: [TopicEntry]
    var pageCount: Int
    var pageIndex: Int
    var title: String?

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case entries = "Entries"
        case pageCount = "PageCount"
        case pageIndex = "PageIndex"
        case data = "Data"
        case title = "Title"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.pageCount = try dataContainer.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
        self.pageIndex = try dataContainer.decodeIfPresent(Int.self, forKey: .pageIndex) ?? 0
        self.title = try dataContainer.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.entries = try dataContainer.decode([TopicEntry].self, forKey: .entries)
       // let entriesContainer = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .entries)
    }
}

struct EntryResponse: ERBaseResponse, ERPagable, ERResponseTitle {
    typealias T = TopicEntry
    
    var pageCount: Int
    var pageIndex: Int
    var success: Bool?
    var message: String?
    var title: String?
    var entries: [TopicEntry]

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case data = "Data"
        case title = "Title"
        case entries = "Entries"
        case pageCount = "PageCount"
        case pageIndex = "PageIndex"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.pageCount = try dataContainer.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
        self.pageIndex = try dataContainer.decodeIfPresent(Int.self, forKey: .pageIndex) ?? 0
        self.title = try dataContainer.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.entries = try dataContainer.decode([TopicEntry].self, forKey: .entries)
    }
}

// MARK: - Popular

