//
//  RestorableState.swift
//  CoreUtil
//
//  Created by yuki on 2022/02/03.
//

import Foundation

@propertyWrapper
public struct RestorableState<Value: RawRepresentable> {
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
    
    public var wrappedValue: Value {
        get { projectedValue.subject.value }
        set {
            projectedValue.subject.send(newValue)
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
    public init(wrappedValue initialValue: Value, _ key: String) {
        let wrappedValue: Value
        
        if let rawValue = UserDefaults.standard.object(forKey: key) as? Value.RawValue, let value = Value(rawValue: rawValue) {
            wrappedValue = value
        } else {
            wrappedValue = initialValue
        }
        
        self.projectedValue = Publisher(wrappedValue)
        self.key = key
    }
}

extension String: RawRepresentable {
    public var rawValue: Self { self }
    public init(rawValue: Self) { self = rawValue }
}

extension Bool: RawRepresentable {
    public var rawValue: Self { self }
    public init(rawValue: Self) { self = rawValue }
}

extension Optional: RawRepresentable {
    public var rawValue: Self { self }
    public init(rawValue: Self) { self = rawValue }
}

extension Int: RawRepresentable {
    public var rawValue: Self { self }
    public init(rawValue: Self) { self = rawValue }
}

extension CGFloat: RawRepresentable {
    public var rawValue: Self { self }
    public init(rawValue: Self) { self = rawValue }
}

extension Double: RawRepresentable {
    public var rawValue: Self { self }
    public init(rawValue: Self) { self = rawValue }
}
