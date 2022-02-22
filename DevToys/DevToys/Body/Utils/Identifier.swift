//
//  Identifier.swift
//  CoreUtil
//
//  Created by yuki on 2021/04/29.
//  Copyright © 2021 yuki. All rights reserved.
//

public enum Identifier {
    @inlinable public static func make(with rule: Identifier.Rule, notContainsIn set: Set<String>) -> String {
        make(with: rule) { !set.contains($0) }
    }
    
    @inlinable public static func make(with rule: Identifier.Rule, _ condition: (String) -> Bool) -> String {
       var identifier = rule.next()
       
       while !condition(identifier) {
           identifier = rule.next()
       }
       
       return identifier
    }
    
    public struct Rule {
        @usableFromInline let next: () -> String
        
        @inlinable public init(_ next: @escaping ()->String) {
            self.next = next
        }
    }
}

extension Identifier.Rule {
    @inlinable public static func uuid() -> Identifier.Rule {
        Identifier.Rule { UUID().uuidString }
    }
    @inlinable public static func brackedNumberPostfix(_ base: String, separtor: String = " ") -> Identifier.Rule {
        var counter = 0
        return Identifier.Rule {
            defer { counter += 1 }
            return counter == 0 ? base : base + "\(separtor)(\(counter))"
        }
    }
    @inlinable public static func numberPostfix(_ base: String, separtor: String = " ") -> Identifier.Rule {
       var counter = 0
       return Identifier.Rule {
           defer { counter += 1 }
           return counter == 0 ? base : "\(base)\(separtor)\(counter)"
       }
    }
}
