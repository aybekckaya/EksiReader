//
//  URL+Extensions.swift
//  Lyrebird
//
//  Created by aybek can kaya on 6.10.2021.
//

import Foundation
import Combine

extension URL {
    public static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
     }

    public func directoryContents() -> [URL] {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)
            return directoryContents
        } catch let error {
            print("Error: \(error)")
            return []
        }
    }

    public func isFileExists(isDirectory: Bool) -> Bool {
        var isDirectory = ObjCBool(isDirectory)
        let isExists = FileManager.default.fileExists(atPath: self.absoluteString.replacingOccurrences(of: "file://", with: ""), isDirectory: &isDirectory)
        return isExists
    }

    public func createFolderIfNotExists() {
        var isDirectory = ObjCBool(true)
        let isExists = FileManager.default.fileExists(atPath: self.absoluteString, isDirectory: &isDirectory)
        guard isExists == false else { return }
        try? FileManager.default.createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
    }

    public func createFileIfNotExists() {
        guard !self.isFileExists(isDirectory: false) else { return }
        FileManager.default.createFile(atPath: self.absoluteString, contents: nil, attributes: nil)
    }

    public func removeFileRx() -> AnyPublisher<Bool, Never> {
        removeFile()
        return Just(true).eraseToAnyPublisher()
    }

    public func removeFolder() {
        guard self.isFileExists(isDirectory: true) else { return }
        try? FileManager.default.removeItem(at: self)
    }

    public func removeFile() {
        guard self.isFileExists(isDirectory: false) else { return }
        try? FileManager.default.removeItem(at: self)
    }

    public func readContentsRx() -> AnyPublisher<Data?, Never> {
        let contents = readContents()
        return Just(contents).eraseToAnyPublisher()
    }

    public func writeDataRx(_ data: Data?) -> AnyPublisher<Bool, Never> {
        writeData(data)
        return Just(true).eraseToAnyPublisher()
    }

    public func readContents() -> Data? {
        guard isFileExists(isDirectory: false) else { return nil }
        let data = try? Data(contentsOf: self)
        return data
    }

    public func writeData(_ data: Data?) {
        guard let data = data else { return }
        self.createFileIfNotExists()
        try? data.write(to: self)
    }

    public func folderSize() -> UInt {
        let contents = self.directoryContents()
        var totalSize: UInt = 0
        contents.forEach { url in
            let size = url.fileSize()
            totalSize += size
        }
        return totalSize
    }

    public func fileSize() -> UInt {
        let attributes = URLFileAttribute(url: self)
        return attributes.fileSize ?? 0
    }

    public func fileAttributes() -> URLFileAttribute {
        return URLFileAttribute(url: self)
    }
}

// MARK: - URLFileAttribute
public class URLFileAttribute {
    var fileSize: UInt? = nil
    var creationDate: Date? = nil
    var modificationDate: Date? = nil

    init() {

    }

    init(url: URL) {
        let path = url.path
        guard let dictionary: [FileAttributeKey: Any] = try? FileManager.default
                .attributesOfItem(atPath: path) else {
            return
        }

        if dictionary.keys.contains(FileAttributeKey.size),
            let value = dictionary[FileAttributeKey.size] as? UInt {
            self.fileSize = value
        }

        if dictionary.keys.contains(FileAttributeKey.creationDate),
            let value = dictionary[FileAttributeKey.creationDate] as? Date {
            self.creationDate = value
        }

        if dictionary.keys.contains(FileAttributeKey.modificationDate),
            let value = dictionary[FileAttributeKey.modificationDate] as? Date {
            self.modificationDate = value
        }
    }
}
