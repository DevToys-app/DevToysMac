//
//  +Functions.swift
//  CoreUtil
//
//  Created by yuki on 2020/10/01.
//  Copyright © 2020 yuki. All rights reserved.
//

precedencegroup PipePrecedence {
    higherThan: NilCoalescingPrecedence
    associativity: left
}

infix operator =>: PipePrecedence
infix operator |>: PipePrecedence
infix operator <=>: PipePrecedence

@discardableResult
@inlinable public func => <T>(lhs: T, rhs: (T) throws -> Void) rethrows -> T {
    try rhs(lhs)
    return lhs
}

@discardableResult
@inlinable public func |> <T, U>(lhs: T, rhs: (T) throws -> U) rethrows -> U {
    try rhs(lhs)
}

@discardableResult
@inlinable public func <=> <T>(lhs: T, rhs: (inout T) throws -> Void) rethrows -> T {
    var lhs = lhs
    try rhs(&lhs)
    return lhs
}
