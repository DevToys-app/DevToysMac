//
//  Extensions.swift
//  DANMAKER
//
//  Created by yuki on 2015/06/24.
//  Copyright © 2015 yuki. All rights reserved.
//

extension RandomAccessCollection {
    @inlinable public func at(_ index: Self.Index) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
}

extension Sequence {
    @inlinable public func count(where condition: (Element) throws -> Bool) rethrows -> Int {
        try self.lazy.filter(condition).count
    }
    @inlinable public func count(while condition: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self {
            if try !condition(element) { return count }
            count += 1
        }
        return count
    }
    
    @inlinable public func firstSome<T>(where condition: (Element) throws -> T?) rethrows -> T? {
        try self.lazy.compactMap(condition).first
    }
    
    @inlinable public func allSome<T>(_ tranceform: (Element) throws -> T?) rethrows -> [T]? {
        var values = [T]()
        for element in self {
            guard let element = try tranceform(element) else { return nil }
            values.append(element)
        }
        return values
    }
}

extension Array {
    public mutating func move(fromIndex: Int, toIndex: Int) {
        assert(indices.contains(fromIndex), "fromIndex '\(fromIndex)' is out of bounds.")
        
        if fromIndex == toIndex { return }
        let removed = self.remove(at: fromIndex)
        
        if fromIndex < toIndex {
            self.insert(removed, at: toIndex - 1)
        } else {
            self.insert(removed, at: toIndex)
        }
    }
    
    public mutating func move<Range: RangeExpression>(fromRange: Range, toIndex: Int) where Range.Bound == Int {
        assert(indices.contains(toIndex), "toIndex '\(toIndex)' is out of bounds.")
        let range = fromRange.relative(to: self)
        
        if range.contains(toIndex) { return }
        
        let removed = self[range]
        self.removeSubrange(range)
        
        if range.upperBound < toIndex + range.count - 1 {
            self.insert(contentsOf: removed, at: toIndex - range.count + 1)
        } else {
            self.insert(contentsOf: removed, at: toIndex)
        }
    }
}

extension Array {
    @discardableResult
    @inlinable public mutating func removeFirst(where condition: (Element) throws -> Bool) rethrows -> Element? {
        for i in 0..<self.count {
            if try condition(self[i]) { return remove(at: i) }
        }
        return nil
    }
}

// MARK: - Equatable Array Extensions
extension Array where Element: Equatable {
    @inlinable @discardableResult public mutating func removeFirst(_ element: Element) -> Element? {
        for index in 0..<count where self[index] == element {
            return remove(at: index)
        }

        return nil
    }
}

extension Sequence where Element: Comparable {
    @inlinable public func max(_ replace: Element) -> Element {  self.max() ?? replace }
    @inlinable public func min(_ replace: Element) -> Element { self.min() ?? replace }
}

extension Dictionary {
    public mutating func arrayAppend<T>(_ value: T, forKey key: Key) where Self.Value == Array<T> {
        if self[key] == nil { self[key] = [] }
        self[key]!.append(value)
    }
    public mutating func arrayAppend<T, S: Sequence>(contentsOf newElements: S, forKey key: Key) where Self.Value == Array<T>, S.Element == T {
        if self[key] == nil { self[key] = [] }
        self[key]!.append(contentsOf: newElements)
    }
}
