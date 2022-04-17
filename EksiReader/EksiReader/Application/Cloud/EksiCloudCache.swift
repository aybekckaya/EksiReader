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
        static let maxSizeInCache: UInt = 20971520 // 20 MB
    }

    init() {
        createDirectoryIfNotExist()
        removeCachedFilesIfNeeded()
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


// MARK: - Cache File Updaters
extension EksiCloudCache {
    private func removeCachedFilesIfNeeded() {
        DispatchQueue.global().async {
            let folderURL = URL
                .documentsDirectory
                .appendingPathComponent(Const.directory)
            let folderSize = folderURL.folderSize()
            guard folderSize >= Const.maxSizeInCache else { return }
            let filesToBeDeleted = self.deletableFileURLs(for: folderSize)
            filesToBeDeleted.forEach { $0.removeFile() }
        }
    }

    private func deletableFileURLs(for folderSize: UInt) -> [URL] {
        struct ERCacheFile {
            let url: URL
            let modificationDate: Date
            let fileSize: UInt
        }

        let diffSize = folderSize - Const.maxSizeInCache
        let cacheFiles: [ERCacheFile] = URL
            .documentsDirectory
            .appendingPathComponent(Const.directory)
            .directoryContents()
            .filter { $0.isDirectory == false }
            .compactMap {
                let attributeModel = URLFileAttribute(url: $0)
                let model = ERCacheFile(url: $0,
                                        modificationDate: attributeModel.modificationDate ?? Date(timeIntervalSince1970: 0),
                                        fileSize: attributeModel.fileSize ?? 0)
                return model
            }.sorted { $0.modificationDate < $1.modificationDate }

        var urls: [URL] = []
        var size: UInt = 0
        cacheFiles.forEach {
            if size < diffSize {
                urls.append($0.url)
            }
            size += $0.fileSize
        }
        return urls
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



