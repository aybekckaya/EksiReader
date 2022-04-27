//
//  Const.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

struct ERKey {
    static let authToken = "AuthToken"
    static let loadingViewTag = 1071
    static let localStorageDirectoryPath = "Local"
    static let localStorageFilePath = "LocalStorage"

    struct NotificationName {
        static let reloadTopicList = Notification.Name("reloadTopicListNotificationName")
        static let changedSortingType = Notification.Name("changedSortingType")
        static let changedEntryFollowStatus =  Notification.Name("changedEntryFollowStatus")
    }
}
