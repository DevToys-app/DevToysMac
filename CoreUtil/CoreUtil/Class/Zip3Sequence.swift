//
//  Zip3Sequence.swift
//  CoreUtil
//
//  Created by yuki on 2022/01/22.
//  Copyright © 2022 yuki. All rights reserved.
//

public func zip<A: Sequence, B: Sequence, C: Sequence>(_ a: A, _ b: B, _ c: C) -> Zip3Sequence<A, B, C> {
    Zip3Sequence(a, b, c)
}
public func zip<A: Sequence, B: Sequence, C: Sequence, D: Sequence>(_ a: A, _ b: B, _ c: C, _ d: D) -> Zip4Sequence<A, B, C, D> {
    Zip4Sequence(a, b, c, d)
}

public struct Zip3Sequence<A: Sequence, B: Sequence, C: Sequence>: Sequence {
    public typealias Element = (A.Element, B.Element, C.Element)
    
    public let a: A
    public let b: B
    public let c: C
    
    public struct Iterator: IteratorProtocol {
        var a: A.Iterator
        var b: B.Iterator
        var c: C.Iterator
        
        mutating public func next() -> Element? {
            if let a = a.next(), let b = b.next(), let c = c.next() { return (a, b, c) }; return nil
        }
    }
    
    public func makeIterator() -> Iterator { Iterator(a: a.makeIterator(), b: b.makeIterator(), c: c.makeIterator()) }
    
    init(_ a: A, _ b: B, _ c: C) {
        self.a = a
        self.b = b
        self.c = c
    }
}

public struct Zip4Sequence<A: Sequence, B: Sequence, C: Sequence, D: Sequence>: Sequence {
    public typealias Element = (A.Element, B.Element, C.Element, D.Element)
    
    public let a: A
    public let b: B
    public let c: C
    public let d: D
    
    public struct Iterator: IteratorProtocol {
        var a: A.Iterator
        var b: B.Iterator
        var c: C.Iterator
        var d: D.Iterator
        
        mutating public func next() -> Element? {
            if let a = a.next(), let b = b.next(), let c = c.next(), let d = d.next() { return (a, b, c, d) }; return nil
        }
    }
    
    public func makeIterator() -> Iterator { Iterator(a: a.makeIterator(), b: b.makeIterator(), c: c.makeIterator(), d: d.makeIterator()) }
    
    init(_ a: A, _ b: B, _ c: C, _ d: D) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
}
