//
//  ERLocalStorage.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation

typealias ERStorageCallback = (ERLocalModel) -> Void

struct ERLocalModel: Codable {
    let favoritedEntries: [Int]
    let favoritedAuthors: [Int]

    enum CodingKeys: String, CodingKey {
        case favoritedEntries = "favoritedEntries"
        case favoritedAuthors = "favoritedAuthors"
    }

    init(favoritedEntries: [Int], favoritedAuthors: [Int]) {
        self.favoritedAuthors = favoritedAuthors
        self.favoritedEntries = favoritedEntries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.favoritedEntries = try container.decodeIfPresent([Int].self, forKey: .favoritedEntries) ?? []
        self.favoritedAuthors = try container.decodeIfPresent([Int].self, forKey: .favoritedAuthors) ?? []
    }

    static var empty: ERLocalModel {
        return .init(favoritedEntries: [], favoritedAuthors: [])
    }
}

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
