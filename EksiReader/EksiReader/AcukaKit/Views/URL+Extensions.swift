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
}
