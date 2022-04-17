//
//  EksiCloudCache.swift
//  EksiReader
//
//  Created by aybek can kaya on 17.04.2022.
//

import Foundation

typealias EksiCloudCacheReadCallback = (Data?) -> Void
class EksiCloudCache {
    enum Const {
        static let directory: String = "CloudCache"
    }

    init() {
        createDirectoryIfNotExist()
    }
}

// MARK: - Public
extension EksiCloudCache {
    func canReadFromCache(for filename: String) -> Bool {
        let url = url(for: filename)
        return url.isFileExists(isDirectory: false)
    }

    func readFromCache(for filename: String, callback: @escaping EksiCloudCacheReadCallback) {
        guard canReadFromCache(for: filename) else {
            callback(nil)
            return
        }

        DispatchQueue.global().async {
            let data = self.url(for: filename).readContents()
            DispatchQueue.main.async {
                callback(data)
            }
        }
    }

    func writeToCache(data: Data, filename: String, callback: @escaping ()->Void) {
        createDirectoryIfNotExist()
        DispatchQueue.global().async {
            let url = self.url(for: filename)
            try? data.write(to: url)
            DispatchQueue.main.async {
                callback()
            }
        }
    }
}

// MARK: - URL Builder
extension EksiCloudCache {
    private func url(for filename: String) -> URL {
        return URL
            .documentsDirectory
            .appendingPathComponent(Const.directory)
            .appendingPathComponent(filename)
            .appendingPathExtension("json")
    }
}


// MARK: - Creator
extension EksiCloudCache {
    private func createDirectoryIfNotExist() {
        let url = URL
            .documentsDirectory
            .appendingPathComponent(Const.directory)
        url.createFolderIfNotExists()
    }
}


// MARK: -
extension EksiCloudCache {

}


// MARK: -
extension EksiCloudCache {

}


// MARK: -
extension EksiCloudCache {

}


// MARK: -
extension EksiCloudCache {

}


// MARK: -
extension EksiCloudCache {

}


// MARK: -
extension EksiCloudCache {

}


// MARK: -
extension EksiCloudCache {

}



