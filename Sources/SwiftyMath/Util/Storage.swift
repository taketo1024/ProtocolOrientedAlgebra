//
//  Storage.swift
//  Sample
//
//  Created by Taketo Sano on 2019/08/22.
//

import Foundation

extension Logger.Id {
    public static let storage = Logger.Id("storage")
}

private let _defaultStorage = Storage(dir: NSTemporaryDirectory() + "SwiftyMath/")

public final class Storage {
    private let fm: FileManager
    public let dir: String
    public let logger: Logger
    
    public static var defaultStorage: Storage {
        return _defaultStorage
    }
    
    public init(dir: String, logger: Logger? = nil) {
        self.fm = FileManager()
        self.dir = (dir.last! == "/") ? dir : dir + "/"
        self.logger = logger ?? Logger.get(.storage)
    }

    public func exists(name: String) -> Bool {
        return fm.fileExists(atPath: fileURL(name).path)
    }
    
    public func save(name: String, data: Data) throws {
        try prepare()
        
        let file = fileURL(name)
        do {
            try data.write(to: file)
        } catch let e {
            logger.error("failed to save data: \(name)")
            throw e
        }
        
        let fmt = ByteCountFormatter()
        fmt.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        fmt.countStyle = .file
        
        logger.info("saved: \(file.path) (\(data.fileSize))")
    }
    
    public func save(name: String, text: String) throws {
        let data = text.data(using: .utf8)!
        try save(name: name, data: data)
    }
    
    public func saveJSON<O: Codable>(name: String, object: O) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(object)
        } catch let e {
            logger.error("couldn't encode given data")
            throw e
        }
        
        try save(name: name, data: data)
    }
    
    public func loadData(name: String) throws -> Data {
        let file = fileURL(name)
        do {
            return try Data(contentsOf: file)
        } catch let e {
            logger.error("couldn't load file: \(file)")
            throw e
        }
    }

    public func loadText(name: String) throws -> String {
        let data = try loadData(name: name)
        guard let text = String(bytes: data, encoding: .utf8) else {
            logger.error("broken text: \(fileURL(name))")
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        }
        return text
    }
    
    public func loadJSON<O: Codable>(name: String) throws -> O {
        let data = try loadData(name: name)
        do {
            return try JSONDecoder().decode(O.self, from: data)
        } catch let e {
            logger.error("broken JSON: \(fileURL(name))")
            throw e
        }
    }
    
    public func delete(_ name: String) throws {
        let file = fileURL(name)
        do {
            try fm.removeItem(at: file)
        } catch let e {
            logger.error("couldn't delete: \(file.path)")
            throw e
        }
        logger.info("delete: \(file.path)")
    }

    private func prepare() throws {
        let fm = FileManager()
        if fm.fileExists(atPath: dir) { return }

        let dirURL = URL(fileURLWithPath: dir)
        do {
            try fm.createDirectory(at: dirURL, withIntermediateDirectories: false, attributes: nil)
        } catch let e {
            logger.error("failed to create dir: \(dir)")
            throw e
        }
        logger.info("created dir: \(dir)")
    }

    private func fileURL(_ name: String) -> URL {
        return URL(fileURLWithPath: dir + name)
    }
}

fileprivate extension Data {
    var fileSize: String {
        let fmt = ByteCountFormatter()
        fmt.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        fmt.countStyle = .file
        return fmt.string(fromByteCount: Int64(count))
    }
}
