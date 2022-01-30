//
//  NSEvent+HotKey.swift
//  ListView
//
//  Created by yuki on 2021/06/28.
//

import Cocoa

extension NSEvent {
    public var hotKey: HotKey {
        HotKey(Key(keyCode: Int(self.keyCode)), self.modifierFlags.intersection(.deviceIndependentFlagsMask))
    }
}

extension NSEvent.ModifierFlags: CustomStringConvertible {
    public var description: String {
        var output = ""
        
        if self.contains(.capsLock) { output += Key.capsLock.description }
        if self.contains(.shift) { output += Key.shift.description }
        if self.contains(.control) { output += Key.control.description }
        if self.contains(.option) { output += Key.option.description }
        if self.contains(.command) { output += Key.command.description }
        if self.contains(.numericPad) { output += "Np" }
        if self.contains(.help) { output += Key.help.description }
        if self.contains(.function) { output += Key.function.description }

        return output
    }
}


