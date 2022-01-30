//
//  Ex+Comparable.swift
//  CoreUtil
//
//  Created by yuki on 2020/04/01.
//  Copyright © 2020 yuki. All rights reserved.
//

public func clamp<Target: Comparable>(_ x: Target, into range: ClosedRange<Target>) -> Target {
    max(range.lowerBound, min(x, range.upperBound))
}

public func clamp<Target: Comparable>(_ x: Target, into range: PartialRangeFrom<Target>) -> Target {
    max(range.lowerBound, x)
}

public func clamp<Target: Comparable>(_ x: Target, into range: PartialRangeThrough<Target>) -> Target {
    min(range.upperBound, x)
}

extension Strideable {
    public func clamped(_ range: Range<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound.advanced(by: -1)))
    }
}

extension Comparable {
    public func clamped(_ range: ClosedRange<Self>) -> Self {
        clamp(self, into: range)
    }
    public func clamped(_ range: PartialRangeFrom<Self>) -> Self {
        clamp(self, into: range)
    }
    public func clamped(_ range: PartialRangeThrough<Self>) -> Self {
        clamp(self, into: range)
    }
}
