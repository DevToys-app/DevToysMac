//
//  Combine+Peek.swift
//  CoreUtil
//
//  Created by yuki on 2022/02/01.
//

import Combine

extension Publisher {
    public func peekError(_ block: @escaping (Failure) -> Void) -> Publishers.MapError<Self, Failure> {
        self.mapError { f -> Failure in block(f); return f }
    }
    public func peek(_ block: @escaping (Output) -> Void) -> Publishers.Map<Self, Output> {
        self.map { block($0); return $0 }
    }
}
