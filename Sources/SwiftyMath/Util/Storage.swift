//
//  Storage.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/23.
//

import Foundation

private var testMode = false

public struct Storage {
    public static func setTestMode(_ flag: Bool) {
        testMode = flag
    }

    public static func exists(_ id: String) -> Bool {
        let fm = FileManager()
        return fm.fileExists(atPath: fileURL(id).path)
    }

    @discardableResult
    public static func save<Obj: Codable>(_ id: String, _ obj: Obj) -> Bool {
        prepare()

        guard let data = try? JSONEncoder().encode(obj) else {
            log("[error] couldn't encode given data: \(id)")
            return false
        }

        let file = fileURL(id)
        do {
            try data.write(to: file)
            log("saved: \(file.path)")
            return true
        } catch {
            log("[error] failed to save data: \(id)")
            return false
        }
    }

    public static func load<Obj: Codable>(_ id: String, _ type: Obj.Type) -> Obj? {
        prepare()

        let file = fileURL(id)
        guard let data = try? Data(contentsOf: file) else {
            log("no such data: \(id)")
            return nil
        }

        guard let obj = try? JSONDecoder().decode(Obj.self, from: data) else {
            log("[error] broken load: \(id)")
            return nil
        }

        return obj
    }

    public static func useCache<Obj: Codable>(_ id: String, initializer: () -> Obj) -> Obj {
        prepare()

        if let obj = load(id, Obj.self) {
            log("use cache: \(id)")
            return obj
        }

        let obj = initializer()
        save(id, obj)
        return obj
    }

    public static func delete(_ id: String) {
        prepare()

        let file = fileURL(id)
        let fm = FileManager()
        if let _ = try? fm.removeItem(at: file) {
            log("delete: \(file.path)")
        } else {
            log("[error] couldn't delete: \(file.path)")
        }
    }

    public static func clear() {
        let fm = FileManager()
        if !fm.fileExists(atPath: dir) { return }

        do {
            try fm.removeItem(atPath: dir)
            log("remove: \(dir)")
        } catch {
            log("[error] failed to clear storage.")
        }
    }

    private static func prepare() {
        let fm = FileManager()
        if fm.fileExists(atPath: dir) { return }

        let dirURL = URL(fileURLWithPath: dir)
        do {
            try fm.createDirectory(at: dirURL, withIntermediateDirectories: false, attributes: nil)
            log("created dir: \(dir)")
        } catch {
            log("[error] failed to create dir: \(dir)")
        }
    }

    public static var dir: String {
        return !testMode ? NSTemporaryDirectory() + "SwiftyMath/" : NSTemporaryDirectory() + "SwiftyMath_test/"
    }

    public static func fileURL(_ id: String) -> URL {
        let name = "\(id).json"
        return URL(fileURLWithPath: dir + name)
    }

    private static func log(_ msg: @autoclosure () -> String) {
        Debug.log(.Storage, msg)
    }
}
