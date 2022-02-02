import CoreGraphics


@inlinable public func round(_ size: CGSize) -> CGSize {
    CGSize(width: round(size.width), height: round(size.height))
}

@inlinable public func abs(_ size: CGSize) -> CGSize {
    CGSize(width: abs(size.width), height: abs(size.height))
}

@inlinable public func sign(_ size: CGSize) -> CGSize {
    CGSize(width: sign(size.width), height: sign(size.height))
}

@inlinable public func min(_ size0: CGSize, _ size1: CGSize) -> CGSize {
    CGSize(width: min(size0.width, size1.width), height: min(size0.height, size1.height))
}

@inlinable public func max(_ size0: CGSize, _ size1: CGSize) -> CGSize {
    CGSize(width: max(size0.width, size1.width), height: max(size0.height, size1.height))
}

extension CGSize {
    @inlinable public func convertToPoint() -> CGPoint {
        CGPoint(x: width, y: height)
    }
    
    @inlinable public var minElement: CGFloat {
        min(abs(self.width), abs(self.height))
    }
    @inlinable public var maxElement: CGFloat {
        max(abs(self.width), abs(self.height))
    }
    @inlinable public var isFinite: Bool {
        width.isFinite && height.isFinite
    }
    
    public static let infinity = CGSize(width: CGFloat.infinity, height: .infinity)
}

extension CGSize {
    @inlinable public func mapWidth(_ tranceform: (CGFloat) -> (CGFloat)) -> CGSize {
        CGSize(width: tranceform(width), height: height)
    }
    @inlinable public func mapHeight(_ tranceform: (CGFloat) -> (CGFloat)) -> CGSize {
        CGSize(width: width, height: tranceform(height))
    }
}

extension CGSize: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        assert(elements.count == 2)
        self.init(width: elements[0], height: elements[1])
    }
}

extension CGSize: AdditiveArithmetic {
    @inlinable public static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    @inlinable public static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    @inlinable public static prefix func - (lhs: CGSize) -> CGSize {
        CGSize(width: -lhs.width, height: -lhs.height)
    }
}

extension CGSize {
    @inlinable public static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    @inlinable public static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    @inlinable public static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    @inlinable public static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    @inlinable public static func *= (lhs: inout CGSize, rhs: CGFloat) {
        lhs.width *= rhs
        lhs.height *= rhs
    }
    @inlinable public static func /= (lhs: inout CGSize, rhs: CGFloat) {
        lhs.width /= rhs
        lhs.height /= rhs
    }
}

extension CGSize: Hashable {
    @inlinable public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}

extension CGSize {
    /// boundingBoxにアスペクトフィットするのに必要な変換レートを返します。
    @inlinable public func aspectFitRatio(fitInside boundingBox: CGSize) -> CGFloat {
        let mW = boundingBox.width / self.width
        let mH = boundingBox.height / self.height

        if mH > mW {
            return boundingBox.width / self.width
        } else {
            return boundingBox.height / self.height
        }
    }

    /// boundingBoxにアスペクトフィルするのに必要な変換レートを返します。
    @inlinable public func aspectFillRatio(fillInside boundingBox: CGSize) -> CGFloat {
        let mW = boundingBox.width / self.width
        let mH = boundingBox.height / self.height

        if mH < mW {
            return boundingBox.width / self.width
        } else {
            return boundingBox.height / self.height
        }
    }
}
