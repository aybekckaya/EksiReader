//
//  EREndpoint.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation


enum EREndpoint {
    enum Const {
        static let baseURL = ""
    }

    case authorizationToken
    case today(page: Int)
}

// MARK: - Request
extension EREndpoint {
    func request() -> NetworkingDataRequest? {
        switch self {
        case .authorizationToken:
            return AuthTokenTokenRequest.request
        case .today(let page):
            return todaysRequest(page: page)
        }
    }
}

// MARK: - Call
extension EREndpoint {
    private func todaysRequest(page: Int) -> NetworkingDataRequest? {
        guard let authToken = EksiCloud.shared.authToken,
                let accessToken = authToken.token
        else {
            return nil
        }

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



/**
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

 */


struct TodaysRequest: Encodable {
    let page: Int

    enum CodingKeys: String, CodingKey {
        case page = "p"
    }
}



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

    static var request: NetworkingDataRequest {
        let reqModel = AuthTokenTokenRequest(Platform: "g",
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
}





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
