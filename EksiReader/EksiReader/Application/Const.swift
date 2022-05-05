//
//  Const.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

struct TopicFollowStatusNotificationModel {
    let topicId: Int
    let isFollowing: Bool
}

struct ERKey {
    static let authToken = "AuthToken"
    static let loadingViewTag = 1071
    static let localStorageDirectoryPath = "Local"
    static let localStorageFilePath = "LocalStorage"
    static let currentThemeKey = "CurrentColorTheme"
    static let usesDeviceConstantsThemeKey = "UsesDeviceConstantsThemeKey"

    struct NotificationName {
        static let reloadTopicEntries = Notification.Name("reloadTopicEntries")
        static let changedSortingType = Notification.Name("changedSortingType")
        static let changedEntryFollowStatus =  Notification.Name("changedEntryFollowStatus")
        static let reloadTopicList =  Notification.Name("reloadTopicList")
        static let colorThemeChanged = Notification.Name("colorThemeChanged")
    }
}
