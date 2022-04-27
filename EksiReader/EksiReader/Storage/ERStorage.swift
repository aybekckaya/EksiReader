//
//  ERLocalStorage.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation

typealias ERStorageCallback = (ERLocalModel) -> Void

struct ERLocalModel: Codable {
    var favoritedEntries: [Int]
    var favoritedAuthors: [Int]
    var blockedAuthors: [Int]
    var followingEntries: [Int]

    enum CodingKeys: String, CodingKey {
        case favoritedEntries = "favoritedEntries"
        case favoritedAuthors = "favoritedAuthors"
        case blockedAuthors = "blockedAuthors"
        case followingEntries = "followingEntries"
    }

    init(favoritedEntries: [Int], favoritedAuthors: [Int], blockedAuthors: [Int], followingEntries: [Int]) {
        self.favoritedAuthors = favoritedAuthors
        self.favoritedEntries = favoritedEntries
        self.blockedAuthors = blockedAuthors
        self.followingEntries = followingEntries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.favoritedEntries = try container.decodeIfPresent([Int].self, forKey: .favoritedEntries) ?? []
        self.favoritedAuthors = try container.decodeIfPresent([Int].self, forKey: .favoritedAuthors) ?? []
        self.blockedAuthors = try container.decodeIfPresent([Int].self, forKey: .blockedAuthors) ?? []
        self.followingEntries = try container.decodeIfPresent([Int].self, forKey: .followingEntries) ?? []
    }

    mutating func setFavoritedEntries(_ value: [Int]) {
        self.favoritedEntries = value
    }

    mutating func setFavoritedAuthors(_ value: [Int]) {
        self.favoritedAuthors = value
    }

    mutating func setBlockedAuthors(_ value: [Int]) {
        self.blockedAuthors = value
    }

    mutating func setFollowingEntries(_ value: [Int]) {
        self.followingEntries = value
    }

    static var empty: ERLocalModel {
        return .init(favoritedEntries: [], favoritedAuthors: [], blockedAuthors: [], followingEntries: [])
    }
}

// MARK: - ERStorage
class ERStorage {
    private(set) var localStorageModel: ERLocalModel = .empty

    // May use as dependency injection while testing
    func setLocalStorageModel(_ model: ERLocalModel) {
        self.localStorageModel = model
    }

    func initialize() {
        self.readLocalStorage { model in
            self.setLocalStorageModel(model)
        }
    }

    func deinitialize() {
        self.writeLocalStorage(localStorageModel) { _ in

        }
    }

    func toggleTopicFollowingStatus(of entryId: Int) {
        changeFollowingStatus(of: entryId)
    }

    func isEntryFollowing(entryId: Int) -> Bool {
        return localStorageModel.followingEntries.contains(entryId)
    }

    func toggleFavoriteStatus(of entryId: Int) {
        changeFavoriteStatus(of: entryId)
    }

    func toggleAuthorBlockingStatus(of authorId: Int) {
        changeAuthorBlockingStatus(of: authorId)
    }

     private func readLocalStorage(callback: @escaping ERStorageCallback) {
        DispatchQueue.global().async {
            self.createLocalStorageFile()
            guard
                let contents = self.jsonFilePath().readContents(),
                let model = try? JSONDecoder().decode(ERLocalModel.self, from: contents)
            else {
                DispatchQueue.main.async {
                    callback(.empty)
                }
                return
            }

            DispatchQueue.main.async {
                callback(model)
            }
        }
    }

     private func writeLocalStorage(_ model: ERLocalModel, callback: @escaping ERStorageCallback) {
        DispatchQueue.global().async {
            self.createLocalStorageFile()
            guard let contents = try? JSONEncoder().encode(model)
            else {
                DispatchQueue.main.async {
                    callback(.empty)
                }
                return
            }
            self.jsonFilePath().writeData(contents)
        }
    }

    private func jsonFilePath() -> URL {
        let directoryPath = URL
            .documentsDirectory
            .appendingPathComponent(ERKey.localStorageDirectoryPath)
        let filePath = directoryPath
            .appendingPathComponent(ERKey.localStorageFilePath)
            .appendingPathExtension("json")
        return filePath
    }

    private  func createLocalStorageFile() {
        let directoryPath = URL
            .documentsDirectory
            .appendingPathComponent(ERKey.localStorageDirectoryPath)
        directoryPath.createFolderIfNotExists()

        let filePath = directoryPath
            .appendingPathComponent(ERKey.localStorageFilePath)
            .appendingPathExtension("json")
        filePath.createFileIfNotExists()
    }
}

// MARK: - Favorite
extension ERStorage {
    private func changeFavoriteStatus(of entryId: Int) {
        var currentFavoritedItems: [Int] = localStorageModel.favoritedEntries
        var newFavoritedItems: [Int] = []
        if localStorageModel.favoritedEntries.contains(entryId) {
            newFavoritedItems = currentFavoritedItems
                .filter { $0 != entryId }
        } else {
            currentFavoritedItems.append(entryId)
            newFavoritedItems = currentFavoritedItems
        }
        localStorageModel.setFavoritedEntries(newFavoritedItems)
    }
}

// MARK: - Block
extension ERStorage {
    private func changeAuthorBlockingStatus(of authorId: Int) {
        var currentFavoritedItems: [Int] = localStorageModel.blockedAuthors
        var newFavoritedItems: [Int] = []
        if localStorageModel.blockedAuthors.contains(authorId) {
            newFavoritedItems = currentFavoritedItems
                .filter { $0 != authorId }
        } else {
            currentFavoritedItems.append(authorId)
            newFavoritedItems = currentFavoritedItems
        }
        localStorageModel.setBlockedAuthors(newFavoritedItems)
    }
}

// MARK: - Follow Entry
extension ERStorage {
    private func changeFollowingStatus(of entryId: Int) {
        var currentFollowingEntries = localStorageModel.followingEntries
        var newFollowingEntries: [Int] = []
        if localStorageModel.followingEntries.contains(entryId) {
            newFollowingEntries = currentFollowingEntries
                .filter { $0 != entryId }
        } else {
            currentFollowingEntries.append(entryId)
            newFollowingEntries = currentFollowingEntries
        }
        localStorageModel.setFollowingEntries(newFollowingEntries)
    }
}
