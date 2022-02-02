//
//  Ex+NUmber.swift
//  CoreUtil
//
//  Created by yuki on 2020/06/24.
//  Copyright © 2020 yuki. All rights reserved.
//

/// Returns `1` when the value greater than or equals to `0`. And returns `-1` when the value smaller than `0`
@inlinable public func sign<T: SignedNumeric & Comparable>(_ value: T) -> T {
    if value >= T.zero {
        return 1
    } else {
        return -1
    }
}

extension Double {
    @inlinable public func rounded(toDecimal fractionDigits: Int) -> Self {
        let multiplier = pow(10, Self(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension Float {
    @inlinable public func rounded(toDecimal fractionDigits: Int) -> Self {
        let multiplier = pow(10, Self(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension CGFloat {
    @inlinable public func rounded(toDecimal fractionDigits: Int) -> Self {
        let multiplier = pow(10, Self(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
