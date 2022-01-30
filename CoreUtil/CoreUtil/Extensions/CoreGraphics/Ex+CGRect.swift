//
//  Ex+CGRect.swift
//  CoreUtil
//
//  Created by yuki on 2020/02/03.
//  Copyright © 2020 yuki. All rights reserved.
//

import Foundation

@inlinable public func round(_ rect: CGRect) -> CGRect {
    CGRect(origin: round(rect.origin), end: round(rect.end))
}

extension CGRect {
    @inlinable public var center: CGPoint {
        @inlinable get { CGPoint(x: midX, y: midY) }
        @inlinable set { self.origin = CGPoint(x: newValue.x - width/2, y: newValue.y - height/2) }
    }

    @inlinable public var end: CGPoint {
        @inlinable get { CGPoint(x: maxX, y: maxY) }
        @inlinable set { self.origin = CGPoint(x: newValue.x - width, y: newValue.y - height) }
    }

    @inlinable public func fattened(by inset: CGFloat) -> CGRect {
        CGRect(origin: self.origin - [inset, inset], size: self.size + [inset, inset]*2)
    }

    @inlinable public func slimmed(by inset: CGFloat) -> CGRect {
        CGRect(origin: self.origin + [inset, inset], size: self.size - [inset, inset]*2)
    }

    @inlinable public func fattened(by edgeInsets: NSEdgeInsets) -> CGRect {
        CGRect(origin: self.origin - [edgeInsets.left, edgeInsets.bottom],
               size: self.size + [edgeInsets.left + edgeInsets.right, edgeInsets.top + edgeInsets.bottom])
    }

    @inlinable public func slimmed(by edgeInsets: NSEdgeInsets) -> CGRect {
        CGRect(origin: self.origin + [edgeInsets.left, edgeInsets.bottom],
               size: self.size - [edgeInsets.left + edgeInsets.right, edgeInsets.top + edgeInsets.bottom])
    }
}

extension CGRect {
    @inlinable public func mapOrigin(_ tranceform: (CGPoint) -> (CGPoint)) -> CGRect {
        CGRect(origin: tranceform(origin), size: size)
    }
    @inlinable public func mapCenter(_ tranceform: (CGPoint) -> (CGPoint)) -> CGRect {
        CGRect(center: tranceform(center), size: size)
    }
    @inlinable public func mapEnd(_ tranceform: (CGPoint) -> (CGPoint)) -> CGRect {
        CGRect(end: tranceform(end), size: size)
    }
    @inlinable public func mapSizePreservingOrigin(_ tranceform: (CGSize) -> (CGSize)) -> CGRect {
        CGRect(origin: origin, size: tranceform(size))
    }
    @inlinable public func mapSizePreservingCenter(_ tranceform: (CGSize) -> (CGSize)) -> CGRect {
        CGRect(center: center, size: tranceform(size))
    }
    @inlinable public func mapSizePreservingEnd(_ tranceform: (CGSize) -> (CGSize)) -> CGRect {
        CGRect(end: end, size: tranceform(size))
    }
}

extension CGRect {
    @inlinable public init(origin: CGPoint) {
        self.init(origin: origin, size: .zero)
    }
    @inlinable public init(size: CGSize) {
        self.init(origin: .zero, size: size)
    }
    @inlinable public init(origin: CGPoint, end: CGPoint) {
        self.init(origin: origin, size: (end - origin).convertToSize())
    }
    @inlinable public init(center: CGPoint, size: CGSize) {
        self.init(origin: center - size.convertToPoint() / 2, size: size)
    }
    @inlinable public init(end: CGPoint, size: CGSize) {
        self.init(origin: end - size.convertToPoint(), size: size)
    }
    @inlinable public init(originX: CGFloat, centerY: CGFloat, size: CGSize) {
        self.init(origin: [originX, centerY - size.height/2], size: size)
    }
    @inlinable public init(centerX: CGFloat, originY: CGFloat, size: CGSize) {
        self.init(origin: [centerX - size.width/2, originY], size: size)
    }
    
    @inlinable public var isFinite: Bool {
        size.isFinite && origin.isFinite
    }
}

extension CGRect {
    @inlinable public static func + (lhs: CGRect, rhs: CGRect) -> CGRect {
        CGRect(origin: lhs.origin + rhs.origin, size: lhs.size + rhs.size)
    }
    @inlinable public static func - (lhs: CGRect, rhs: CGRect) -> CGRect {
        CGRect(origin: lhs.origin - rhs.origin, size: lhs.size - rhs.size)
    }
}

extension CGRect: Hashable {
    @inlinable public func hash(into hasher: inout Hasher) {
        hasher.combine(size)
        hasher.combine(origin)
    }
}

extension Collection where Element == CGRect {
    @inlinable public var enclosingRect: CGRect {
        if self.isEmpty { return .zero }
        
        var minX: CGFloat = .infinity
        var minY: CGFloat = .infinity
        var maxX: CGFloat = -.infinity
        var maxY: CGFloat = -.infinity
        
        for rect in self {
            if minX > rect.origin.x { minX = rect.origin.x }
            if minY > rect.origin.y { minY = rect.origin.y }
            let _maxX = rect.origin.x + rect.size.width
            if maxX < _maxX { maxX = _maxX }
            let _maxY = rect.origin.y + rect.size.height
            if maxY < _maxY { maxY = _maxY }
        }
        
        let rect = CGRect(origin: [minX, minY], end: [maxX, maxY])
        return rect
    }
}

extension FloatingPoint {
    @inlinable public func isFiniteOrZero() -> Self { isFinite ? self : .zero }
}
extension CGPoint {
    @inlinable public func isFiniteOrZero() -> CGPoint { isFinite ? self : .zero }
}
extension CGSize {
    @inlinable public func isFiniteOrZero() -> CGSize { isFinite ? self : .zero }
}
extension CGRect {
    @inlinable public func isFiniteOrZero() -> CGRect { isFinite ? self : .zero }
}

