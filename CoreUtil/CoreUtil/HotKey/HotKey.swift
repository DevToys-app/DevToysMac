//
//  KeyboardShortcut.swift
//  ListView
//
//  Created by yuki on 2021/06/28.
//

import Carbon
import Cocoa

public struct HotKey: Hashable {
    public let key: Key?
    public let modifiers: NSEvent.ModifierFlags
    
    public init(_ key: Key?, _ modifiers: NSEvent.ModifierFlags = []) {
        self.key = key
        self.modifiers = modifiers
    }
}

extension HotKey {
    public static let open = HotKey(.o, .command)
    public static let copy = HotKey(.c, .command)
    public static let paste = HotKey(.v, .command)
    public static let cut = HotKey(.x, .command)
    public static let duplicate = HotKey(.d, .command)
    public static let save = HotKey(.s, .command)
    public static let undo = HotKey(.z, .command)
    public static let selectAll = HotKey(.a, .command)
    public static let redo = HotKey(.z, [.command, .shift])
    public static let go = HotKey(.rightBracket, .command)
    public static let back = HotKey(.leftBracket, .command)
    public static let print = HotKey(.p, .command)
    public static let delete = HotKey(.delete)
    public static let tab = HotKey(.tab)
    public static let backtab = HotKey(.tab, .shift)
    public static let escape = HotKey(.escape)
    public static let enter = HotKey(.keypadEnter)
    public static let space = HotKey(.space)
    public static let `return` = HotKey(.return)
    public static let leftArrow = HotKey(.leftArrow, [.numericPad, .function])
    public static let rightArrow = HotKey(.rightArrow, [.numericPad, .function])
    public static let upArrow = HotKey(.upArrow, [.numericPad, .function])
    public static let downArrow = HotKey(.downArrow, [.numericPad, .function])
    public static let leftShiftArrow = HotKey(.leftArrow, [.numericPad, .function, .shift])
    public static let rightShiftArrow = HotKey(.rightArrow, [.numericPad, .function, .shift])
    public static let upShiftArrow = HotKey(.upArrow, [.numericPad, .function, .shift])
    public static let downShiftArrow = HotKey(.downArrow, [.numericPad, .function, .shift])
}

extension HotKey: CustomStringConvertible {
    public var description: String {
        var output = modifiers.description
        if let key = key {
            output += key.description
        }
        return output
    }
}

extension NSEvent.ModifierFlags: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
