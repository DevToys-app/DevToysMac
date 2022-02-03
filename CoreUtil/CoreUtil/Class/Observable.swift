//
//  Property.swift
//  CoreUtil
//
//  Created by yuki on 2020/07/06.
//  Copyright © 2020 yuki. All rights reserved.
//

import Combine

/// Publishedの10倍軽いPropertyWrapper
@propertyWrapper
public struct Observable<Value> {

    public struct Publisher: Combine.Publisher {
        public typealias Output = Value
        public typealias Failure = Never
        
        @usableFromInline let subject: CurrentValueSubject<Value, Never>
        
        @inlinable init(_ value: Value) { self.subject = CurrentValueSubject(value) }
        
        @inlinable public func receive<S: Subscriber>(subscriber: S) where S.Failure == Self.Failure, S.Input == Self.Output {
            self.subject.receive(subscriber: subscriber)
        }
    }
    
    public let projectedValue: Publisher
    
    @inlinable public var wrappedValue: Value {
        @inlinable get { projectedValue.subject.value }
        @inlinable set { projectedValue.subject.send(newValue) }
    }
    @inlinable public init(wrappedValue value: Value) {
        self.projectedValue = Publisher(value)
    }
}
