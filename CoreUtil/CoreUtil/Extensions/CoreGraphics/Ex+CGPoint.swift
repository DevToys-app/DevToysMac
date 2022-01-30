//
//  Ex+CGPoint.swift
//  Topica
//
//  Created by yuki on 2019/10/27.
//  Copyright © 2019 yuki. All rights reserved.
//

import CoreGraphics

@inlinable public func round(_ point: CGPoint) -> CGPoint {
    CGPoint(x: round(point.x), y: round(point.y))
}

@inlinable public func ceil(_ point: CGPoint) -> CGPoint {
    CGPoint(x: ceil(point.x), y: ceil(point.y))
}

@inlinable public func floor(_ point: CGPoint) -> CGPoint {
    CGPoint(x: floor(point.x), y: floor(point.y))
}

@inlinable public func sign(_ point: CGPoint) -> CGPoint {
    CGPoint(x: sign(point.x), y: sign(point.y))
}

@inlinable public func min(_ point0: CGPoint, _ point1: CGPoint) -> CGPoint {
    CGPoint(x: min(point0.x, point1.x), y: min(point0.y, point1.y))
}

@inlinable public func max(_ point0: CGPoint, _ point1: CGPoint) -> CGPoint {
    CGPoint(x: max(point0.x, point1.x), y: max(point0.y, point1.y))
}

@inlinable public func abs(_ point: CGPoint) -> CGFloat {
    sqrt(point.x * point.x + point.y * point.y)
}

@inlinable public func abs2(_ point: CGPoint) -> CGFloat {
    point.x * point.x + point.y * point.y
}

@inlinable public func clamp(_ point: CGPoint, in rect: CGRect) -> CGPoint {
    CGPoint(x: clamp(point.x, into: rect.minX...rect.maxX), y: clamp(point.y, into: rect.minY...rect.maxY))
}

@inlinable public func dot(_ point0: CGPoint, _ point1: CGPoint) -> CGFloat {
    point0.x * point1.x + point0.y * point1.y
}

extension CGPoint {
    public static let infinity = CGSize(width: CGFloat.infinity, height: .infinity)
    
    @inlinable public func convertToSize() -> CGSize {
        CGSize(width: x, height: y)
    }

    @inlinable public var unitVector: CGPoint {
        let absValue = abs(self)
        if absValue == 0 { return .zero }
        return self / absValue
    }
    
    @inlinable public var isFinite: Bool {
        x.isFinite && y.isFinite
    }
}

extension CGPoint {
    @inlinable public func map(_ tranceform: (CGFloat) -> (CGFloat)) -> CGPoint {
        mapX(tranceform).mapY(tranceform)
    }
    @inlinable public func mapX(_ tranceform: (CGFloat) -> (CGFloat)) -> CGPoint {
        CGPoint(x: tranceform(x), y: y)
    }
    @inlinable public func mapY(_ tranceform: (CGFloat) -> (CGFloat)) -> CGPoint {
        CGPoint(x: x, y: tranceform(y))
    }
}

extension CGPoint: ExpressibleByArrayLiteral {
    @inlinable public init(arrayLiteral elements: CGFloat...) {
        assert(elements.count == 2)
        self.init(x: elements[0], y: elements[1])
    }
}

extension CGPoint: Hashable {
    @inlinable public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension CGPoint: AdditiveArithmetic {
    @inlinable public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    @inlinable public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    @inlinable public static prefix func - (lhs: CGPoint) -> CGPoint {
        CGPoint(x: -lhs.x, y: -lhs.y)
    }
    @inlinable public static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    @inlinable public static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension CGPoint {
    @inlinable public static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    @inlinable public static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    @inlinable public static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    @inlinable public static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    @inlinable public static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    @inlinable public static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}
