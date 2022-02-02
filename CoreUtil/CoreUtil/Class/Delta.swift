//
//  Delta.swift
//  CoreUtil
//
//  Created by yuki on 2020/05/14.
//  Copyright © 2020 yuki. All rights reserved.
//

public enum Delta<Value> {
    case to(Value)
    case by(Value)
}

extension Delta {
    @inlinable public func map<T>(_ tranceform: (Value) throws -> T) rethrows -> Delta<T> {
        switch self {
        case .to(let value): return .to(try tranceform(value))
        case .by(let value): return .by(try tranceform(value))
        }
    }
    
    @inlinable public func reduce(_ initialValue: Value, _ tranceform: (Value, Value) throws -> Value) rethrows -> Value {
        switch self {
        case .to(let value): return value
        case .by(let value): return try tranceform(initialValue, value)
        }
    }
    
    @inlinable public func takeValue() -> Value {
        switch self {
        case .to(let value): return value
        case .by(let value): return value
        }
    }
    
    @inlinable public func apply(_ initialValue: inout Value, _ tranceform: (Value, Value) throws -> Value) rethrows {
        initialValue = try reduce(initialValue, tranceform)
    }
}

extension Delta where Value: AdditiveArithmetic {
    @inlinable public func reduce(_ initialValue: Value) -> Value {
        reduce(initialValue, +)
    }
    @inlinable public func apply(_ initialValue: inout Value) {
        apply(&initialValue, +)
    }
    
    @inlinable public static func += (_ initialValue: inout Value, delta: Delta<Value>) {
        delta.apply(&initialValue)
    }
}

extension Delta where Value: RangeReplaceableCollection {
    @inlinable public func reduce(_ initialValue: Value) -> Value {
        reduce(initialValue, +)
    }
    @inlinable public func apply(_ initialValue: inout Value) {
        apply(&initialValue, +)
    }
    
    @inlinable public static func += (_ initialValue: inout Value, delta: Delta<Value>) {
        delta.apply(&initialValue)
    }
}

extension Delta: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .by(let value): try container.encode(["by": value])
        case .to(let value): try container.encode(["to": value])
        }
    }
}

extension Delta: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let content = try container.decode([String: Value].self)
        
        guard let (key, value) = content.first else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Empty container")
        }
        
        switch key {
        case "by": self = .by(value)
        case "to": self = .to(value)
        default: throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unkown key '\(key)'")
        }
    }
}
