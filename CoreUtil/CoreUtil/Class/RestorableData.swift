//
//  RestorableData.swift
//  CoreUtil
//
//  Created by yuki on 2022/02/03.
//

import Cocoa

extension FileManager {
    public static let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.noname.app")
}

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()
private let restorableDataURL = FileManager.temporaryDirectoryURL.appendingPathComponent("RestorableData") => {
    try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
}

@propertyWrapper
public struct RestorableData<Value: Codable> {
    public struct Publisher: Combine.Publisher {
        public typealias Output = Value
        public typealias Failure = Never
        
        let subject: CurrentValueSubject<Value, Never>
        
        init(_ value: Value) { self.subject = CurrentValueSubject(value) }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Self.Failure, S.Input == Self.Output {
            self.subject.receive(subscriber: subscriber)
        }
    }
    
    public let projectedValue: Publisher
    public let key: String
    public let fileURL: URL
    
    public var wrappedValue: Value {
        get { projectedValue.subject.value }
        set {
            projectedValue.subject.send(newValue)
            do { try encoder.encode(newValue).write(to: fileURL) } catch {}
        }
    }
    public init(wrappedValue initialValue: Value, _ key: String) {
        self.key = key
        self.fileURL = restorableDataURL.appendingPathComponent(key + ".json")
        
        let wrappedValue: Value
        do {
            wrappedValue = try decoder.decode(Value.self, from: Data(contentsOf: fileURL))
        } catch {
            wrappedValue = initialValue
        }
        
        self.projectedValue = Publisher(wrappedValue)
    }
}

final public class NSImageContainer: Codable {
    static let dataDirectoryURL = FileManager.temporaryDirectoryURL.appendingPathComponent("NSImageContainer") => {
        try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    public let image: NSImage
    public let id: String
    public init(_ image: NSImage) {
        self.image = image
        self.id = UUID().uuidString
    }
    
    public static func wrap(_ image: NSImage) -> NSImageContainer { NSImageContainer(image) }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
        let fileURL = NSImageContainer.dataDirectoryURL.appendingPathComponent(id)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            try image.tiffRepresentation?.write(to: fileURL)
        }
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let id = try container.decode(String.self)
        let fileURL = NSImageContainer.dataDirectoryURL.appendingPathComponent(id)
        guard let image = NSImage(contentsOf: fileURL) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No image"))
        }
        self.image = image
        self.id = id
    }
}
