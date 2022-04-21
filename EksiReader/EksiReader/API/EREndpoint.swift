//
//  EREndpoint.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation
import SwiftHash

protocol EksiRequestable {
    func request() -> NetworkingDataRequest?
}

enum EREndpoint {
    enum Const {
        static let changablePageIndex = -1
        static let baseURL: String = "https://api.eksisozluk.com/"
        static let version: String = "v2"
        static let clientSecret: String = "eabb8841-258d-4561-89a6-66c6501dee83"
        static let clientSecretHeader: NetworkingRequestHeader = .init(key: "Client-Secret", value: Const.clientSecret)
        static let clientUniqueId: String = "1a62383d-742e-4bcf-bf77-2fe1a1edcd39"
        static let apiSecret: String = "68f779c5-4d39-411a-bd12-cbcc50dc83dd"
        static let build: String = "51"
        static let buildVersion: String = "2.0.0"
        static let platform: String = "g"
    }

    case authorizationToken
    case today(page: Int)
    case topic(id: Int, page: Int)
    case entry(id: Int)
    case popular()
}

// MARK: - Identifier
extension EREndpoint {
    private func identifier() -> String {
        switch self {
        case .authorizationToken:
            return "AuthorizationToken"
        case .today(let page):
            return "TodayRequest-Page-\(page)"
        case .topic(let id, let page):
            return "TodayTopic-Page-\(page)-id-\(id)"
        case .entry(let id):
            return "EntryDetail-Id-\(id)"
        }
    }
}

// MARK: - Hash
extension EREndpoint {
    func hash() -> String {
        let req = buildURL() + identifier()
        return MD5(req)
    }
}

// MARK: - Request
extension EREndpoint {
    func request() -> NetworkingDataRequest? {
        switch self {
        case .authorizationToken:
            return authRequest()
        case .today(let page):
            return todaysRequest(page: page)
        case .topic(_, let page):
            return topicRequest(page: page)
        case .entry(let id):
            return entryRequest(id: id)
        }
    }
}

// https://api.eksisozluk.com/v2/entry/102
// MARK: - URL Builder
extension EREndpoint {
    private func buildURL() -> String {
        switch self {
        case .authorizationToken:
            return Const.baseURL + Const.version + "/account/anonymoustoken"
        case .today( _ ):
            return Const.baseURL + Const.version + "/index/today/"
        case .topic(let id, _ ):
            return Const.baseURL + Const.version + "/topic/\(id)"
        case .entry(let id):
            return Const.baseURL + Const.version + "/entry/\(id)"
        }

    }
}

// MARK: - Requests
extension EREndpoint {
    private func authRequest() -> NetworkingDataRequest? {
        let reqModel = AuthTokenTokenRequest(Platform: Const.platform,
                                             Version: Const.buildVersion,
                                             Build: Const.build,
                                             ApiSecret: Const.apiSecret,
                                             ClientSecret: Const.clientSecret,
                                             ClientUniqueId: Const.clientUniqueId)
        let headers: [NetworkingRequestHeader] = [
            .contentTypeValue(.urlEncodedForm)
        ]

        let url = buildURL()
        let req = NetworkingDataRequest(url: url, method: .post)
            .requestModel(reqModel)
            .headers(headers)

        return req
    }

    private func entryRequest(id: Int) -> NetworkingDataRequest? {
        let reqModel = EntryRequest(id: id)
        let headers: [NetworkingRequestHeader] = [
            .contentTypeValue(.urlEncodedForm),
           // .bearerToken(accessToken),
            EREndpoint.Const.clientSecretHeader
        ]
        let url = buildURL()
        let req = NetworkingDataRequest(url: url, method: .get)
            .headers(headers)
            .requestModel(reqModel)
        return req
    }

    private func todaysRequest(page: Int) -> NetworkingDataRequest? {
        let reqModel = TodaysRequest(page: page)
        let headers: [NetworkingRequestHeader] = [
            .contentTypeValue(.urlEncodedForm),
           // .bearerToken(accessToken),
            EREndpoint.Const.clientSecretHeader
        ]

        let url = buildURL()
        let req = NetworkingDataRequest(url: url, method: .get)
            .headers(headers)
            .requestModel(reqModel)

        return req
    }

    private func topicRequest(page: Int) -> NetworkingDataRequest? {
        let reqModel = TodayTopicRequest(page: page)
        let headers: [NetworkingRequestHeader] = [
            .contentTypeValue(.urlEncodedForm),
           // .bearerToken(accessToken),
            EREndpoint.Const.clientSecretHeader
        ]

        let url = buildURL()
        let req = NetworkingDataRequest(url: url, method: .get)
            .headers(headers)
            .requestModel(reqModel)

        return req
    }
}











/**

 //
 //  EksiReaderCloud.swift
 //  UIElementsApp
 //
 //  Created by aybek can kaya on 4.04.2022.
 //

 import Foundation


 enum EksiReaderCloud {
     case anonymoustoken
     case today(page: Int, accessToken: String)
 }

 extension EksiReaderCloud {
     func request() -> NetworkingDataRequest {
         switch self {
         case .anonymoustoken:
             return anonymousRequest()
         case .today(let page, let accessToken):
             return todaysRequest(page: page, accessToken: accessToken)
         }

     }

     private func anonymousRequest() -> NetworkingDataRequest {
         let reqModel = AnonymousTokenRequest(Platform: "g",
                                              Version: "2.0.0",
                                              Build: "51",
                                              ApiSecret: "68f779c5-4d39-411a-bd12-cbcc50dc83dd",
                                              ClientSecret: "eabb8841-258d-4561-89a6-66c6501dee83",
                                              ClientUniqueId: "1a62383d-742e-4bcf-bf77-2fe1a1edcd39")
         let headers: [NetworkingRequestHeader] = [
             .contentTypeValue(.urlEncodedForm)
         ]
       //  let reqData = try! JSONEncoder().encode(reqModel)

         let req = NetworkingDataRequest(url: "https://api.eksisozluk.com/v2/account/anonymoustoken",
                                         method: .post)
             .requestModel(reqModel)
             .headers(headers)

         return req
     }

     private func todaysRequest(page: Int, accessToken: String) -> NetworkingDataRequest {
         let reqModel = TodaysRequest(page: page)
         let headers: [NetworkingRequestHeader] = [
             .contentTypeValue(.urlEncodedForm),
             .bearerToken(accessToken),
             .init(key: "Client-Secret", value: "eabb8841-258d-4561-89a6-66c6501dee83")
         ]

         let url = "https://api.eksisozluk.com/v2/index/today/"
         let req = NetworkingDataRequest(url: url,
                                         method: .get)
             .headers(headers)
             .requestModel(reqModel)

         return req
     }
 }

 // MARK: - Requests

 struct TodaysRequest: Encodable {
     let page: Int

     enum CodingKeys: String, CodingKey {
         case page = "p"
     }
 }

 struct AnonymousTokenRequest: Encodable {
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

 // MARK: - Responses
 struct AnonymousTokenResponse: Decodable {
     let success: Bool
     let message: String?
     let accessToken: String?

     enum CodingKeys: String, CodingKey {
         case success = "Success"
         case message = "Message"
         case accessToken = "access_token"
         case data = "Data"
     }

     init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         self.success = try container.decode(Bool.self, forKey: .success)
         self.message = try container.decodeIfPresent(String.self, forKey: .message)
         let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
         self.accessToken = try dataContainer.decodeIfPresent(String.self, forKey: .accessToken)
     }
 }

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




 */
