//
//  ChannelManager.swift
//  EksiReader
//
//  Created by aybek can kaya on 22.04.2022.
//

import Foundation


struct Channel: Codable {
    let chanelId: Int
    let enabled: Bool

    enum CodingKeys: String, CodingKey {
        case chanelId = "channelId"
        case enabled = "enabled"
    }
}

class ChannelFilter: Codable {
    var channels: [Channel] = []

    enum CodingKeys: String, CodingKey {
        case channels = "Filters"
    }

    static func allChannels(excludeIDs: [Int]) -> ChannelFilter {
        var filter = ChannelFilter()
        var arrChannels: [Channel] = []

        for index in 1 ..< 100 {
            let channel = Channel(chanelId: index,
                                  enabled: !excludeIDs.contains(index))
            arrChannels.append(channel)
        }

        filter.channels = arrChannels
        return filter
    }
}

class ChannelManager {
    private(set) var currentChannelFilter: ChannelFilter = .allChannels(excludeIDs: [])


}
