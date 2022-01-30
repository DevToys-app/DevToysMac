//
//  Key.swift
//  ListView
//
//  Created by yuki on 2021/06/28.
//

import Carbon

public enum Key {
    // MARK: - Letters -
    case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z

    // MARK: - Numbers -
    case zero, one, two, three, four, five, six, seven, eight, nine

    // MARK: - Symbols -
    case period, quote, rightBracket, semicolon, slash, backslash, comma, equal, grave, leftBracket, minus

    // MARK: - White Spaces -
    case space, tab, `return`

    // MARK: - Modifiers -
    case command, rightCommand, option, rightOption, control, rightControl, shift, rightShift, function, capsLock

    // MARK: - Navigation
    case pageUp, pageDown, home, end, upArrow, rightArrow, downArrow, leftArrow

    // MARK: - Functions
    case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20

    // MARK: - Keypad
    case keypad0, keypad1, keypad2, keypad3, keypad4, keypad5, keypad6, keypad7, keypad8, keypad9, keypadClear, keypadDecimal, keypadDivide, keypadEnter, keypadEquals, keypadMinus, keypadMultiply, keypadPlus

    // MARK: - Misc
    case escape, delete, forwardDelete, help, volumeUp, volumeDown, mute

    public init?(keyCode: Int) {
        switch keyCode {
        case kVK_ANSI_A: self = .a
        case kVK_ANSI_S: self = .s
        case kVK_ANSI_D: self = .d
        case kVK_ANSI_F: self = .f
        case kVK_ANSI_H: self = .h
        case kVK_ANSI_G: self = .g
        case kVK_ANSI_Z: self = .z
        case kVK_ANSI_X: self = .x
        case kVK_ANSI_C: self = .c
        case kVK_ANSI_V: self = .v
        case kVK_ANSI_B: self = .b
        case kVK_ANSI_Q: self = .q
        case kVK_ANSI_W: self = .w
        case kVK_ANSI_E: self = .e
        case kVK_ANSI_R: self = .r
        case kVK_ANSI_Y: self = .y
        case kVK_ANSI_T: self = .t
        case kVK_ANSI_1: self = .one
        case kVK_ANSI_2: self = .two
        case kVK_ANSI_3: self = .three
        case kVK_ANSI_4: self = .four
        case kVK_ANSI_6: self = .six
        case kVK_ANSI_5: self = .five
        case kVK_ANSI_Equal: self = .equal
        case kVK_ANSI_9: self = .nine
        case kVK_ANSI_7: self = .seven
        case kVK_ANSI_Minus: self = .minus
        case kVK_ANSI_8: self = .eight
        case kVK_ANSI_0: self = .zero
        case kVK_ANSI_RightBracket: self = .rightBracket
        case kVK_ANSI_O: self = .o
        case kVK_ANSI_U: self = .u
        case kVK_ANSI_LeftBracket: self = .leftBracket
        case kVK_ANSI_I: self = .i
        case kVK_ANSI_P: self = .p
        case kVK_ANSI_L: self = .l
        case kVK_ANSI_J: self = .j
        case kVK_ANSI_Quote: self = .quote
        case kVK_ANSI_K: self = .k
        case kVK_ANSI_Semicolon: self = .semicolon
        case kVK_ANSI_Backslash: self = .backslash
        case kVK_ANSI_Comma: self = .comma
        case kVK_ANSI_Slash: self = .slash
        case kVK_ANSI_N: self = .n
        case kVK_ANSI_M: self = .m
        case kVK_ANSI_Period: self = .period
        case kVK_ANSI_Grave: self = .grave
        case kVK_ANSI_KeypadDecimal: self = .keypadDecimal
        case kVK_ANSI_KeypadMultiply: self = .keypadMultiply
        case kVK_ANSI_KeypadPlus: self = .keypadPlus
        case kVK_ANSI_KeypadClear: self = .keypadClear
        case kVK_ANSI_KeypadDivide: self = .keypadDivide
        case kVK_ANSI_KeypadEnter: self = .keypadEnter
        case kVK_ANSI_KeypadMinus: self = .keypadMinus
        case kVK_ANSI_KeypadEquals: self = .keypadEquals
        case kVK_ANSI_Keypad0: self = .keypad0
        case kVK_ANSI_Keypad1: self = .keypad1
        case kVK_ANSI_Keypad2: self = .keypad2
        case kVK_ANSI_Keypad3: self = .keypad3
        case kVK_ANSI_Keypad4: self = .keypad4
        case kVK_ANSI_Keypad5: self = .keypad5
        case kVK_ANSI_Keypad6: self = .keypad6
        case kVK_ANSI_Keypad7: self = .keypad7
        case kVK_ANSI_Keypad8: self = .keypad8
        case kVK_ANSI_Keypad9: self = .keypad9
        case kVK_Return: self = .`return`
        case kVK_Tab: self = .tab
        case kVK_Space: self = .space
        case kVK_Delete: self = .delete
        case kVK_Escape: self = .escape
        case kVK_Command: self = .command
        case kVK_Shift: self = .shift
        case kVK_CapsLock: self = .capsLock
        case kVK_Option: self = .option
        case kVK_Control: self = .control
        case kVK_RightCommand: self = .rightCommand
        case kVK_RightShift: self = .rightShift
        case kVK_RightOption: self = .rightOption
        case kVK_RightControl: self = .rightControl
        case kVK_Function: self = .function
        case kVK_F17: self = .f17
        case kVK_VolumeUp: self = .volumeUp
        case kVK_VolumeDown: self = .volumeDown
        case kVK_Mute: self = .mute
        case kVK_F18: self = .f18
        case kVK_F19: self = .f19
        case kVK_F20: self = .f20
        case kVK_F5: self = .f5
        case kVK_F6: self = .f6
        case kVK_F7: self = .f7
        case kVK_F3: self = .f3
        case kVK_F8: self = .f8
        case kVK_F9: self = .f9
        case kVK_F11: self = .f11
        case kVK_F13: self = .f13
        case kVK_F16: self = .f16
        case kVK_F14: self = .f14
        case kVK_F10: self = .f10
        case kVK_F12: self = .f12
        case kVK_F15: self = .f15
        case kVK_Help: self = .help
        case kVK_Home: self = .home
        case kVK_PageUp: self = .pageUp
        case kVK_ForwardDelete: self = .forwardDelete
        case kVK_F4: self = .f4
        case kVK_End: self = .end
        case kVK_F2: self = .f2
        case kVK_PageDown: self = .pageDown
        case kVK_F1: self = .f1
        case kVK_LeftArrow: self = .leftArrow
        case kVK_RightArrow: self = .rightArrow
        case kVK_DownArrow: self = .downArrow
        case kVK_UpArrow: self = .upArrow
        default: return nil
        }
    }
    
    public var keyCode: Int {
        switch self {
        case .a: return kVK_ANSI_A
        case .s: return kVK_ANSI_S
        case .d: return kVK_ANSI_D
        case .f: return kVK_ANSI_F
        case .h: return kVK_ANSI_H
        case .g: return kVK_ANSI_G
        case .z: return kVK_ANSI_Z
        case .x: return kVK_ANSI_X
        case .c: return kVK_ANSI_C
        case .v: return kVK_ANSI_V
        case .b: return kVK_ANSI_B
        case .q: return kVK_ANSI_Q
        case .w: return kVK_ANSI_W
        case .e: return kVK_ANSI_E
        case .r: return kVK_ANSI_R
        case .y: return kVK_ANSI_Y
        case .t: return kVK_ANSI_T
        case .one: return kVK_ANSI_1
        case .two: return kVK_ANSI_2
        case .three: return kVK_ANSI_3
        case .four: return kVK_ANSI_4
        case .six: return kVK_ANSI_6
        case .five: return kVK_ANSI_5
        case .equal: return kVK_ANSI_Equal
        case .nine: return kVK_ANSI_9
        case .seven: return kVK_ANSI_7
        case .minus: return kVK_ANSI_Minus
        case .eight: return kVK_ANSI_8
        case .zero: return kVK_ANSI_0
        case .rightBracket: return kVK_ANSI_RightBracket
        case .o: return kVK_ANSI_O
        case .u: return kVK_ANSI_U
        case .leftBracket: return kVK_ANSI_LeftBracket
        case .i: return kVK_ANSI_I
        case .p: return kVK_ANSI_P
        case .l: return kVK_ANSI_L
        case .j: return kVK_ANSI_J
        case .quote: return kVK_ANSI_Quote
        case .k: return kVK_ANSI_K
        case .semicolon: return kVK_ANSI_Semicolon
        case .backslash: return kVK_ANSI_Backslash
        case .comma: return kVK_ANSI_Comma
        case .slash: return kVK_ANSI_Slash
        case .n: return kVK_ANSI_N
        case .m: return kVK_ANSI_M
        case .period: return kVK_ANSI_Period
        case .grave: return kVK_ANSI_Grave
        case .keypadDecimal: return kVK_ANSI_KeypadDecimal
        case .keypadMultiply: return kVK_ANSI_KeypadMultiply
        case .keypadPlus: return kVK_ANSI_KeypadPlus
        case .keypadClear: return kVK_ANSI_KeypadClear
        case .keypadDivide: return kVK_ANSI_KeypadDivide
        case .keypadEnter: return kVK_ANSI_KeypadEnter
        case .keypadMinus: return kVK_ANSI_KeypadMinus
        case .keypadEquals: return kVK_ANSI_KeypadEquals
        case .keypad0: return kVK_ANSI_Keypad0
        case .keypad1: return kVK_ANSI_Keypad1
        case .keypad2: return kVK_ANSI_Keypad2
        case .keypad3: return kVK_ANSI_Keypad3
        case .keypad4: return kVK_ANSI_Keypad4
        case .keypad5: return kVK_ANSI_Keypad5
        case .keypad6: return kVK_ANSI_Keypad6
        case .keypad7: return kVK_ANSI_Keypad7
        case .keypad8: return kVK_ANSI_Keypad8
        case .keypad9: return kVK_ANSI_Keypad9
        case .`return`: return kVK_Return
        case .tab: return kVK_Tab
        case .space: return kVK_Space
        case .delete: return kVK_Delete
        case .escape: return kVK_Escape
        case .command: return kVK_Command
        case .shift: return kVK_Shift
        case .capsLock: return kVK_CapsLock
        case .option: return kVK_Option
        case .control: return kVK_Control
        case .rightCommand: return kVK_RightCommand
        case .rightShift: return kVK_RightShift
        case .rightOption: return kVK_RightOption
        case .rightControl: return kVK_RightControl
        case .function: return kVK_Function
        case .f17: return kVK_F17
        case .volumeUp: return kVK_VolumeUp
        case .volumeDown: return kVK_VolumeDown
        case .mute: return kVK_Mute
        case .f18: return kVK_F18
        case .f19: return kVK_F19
        case .f20: return kVK_F20
        case .f5: return kVK_F5
        case .f6: return kVK_F6
        case .f7: return kVK_F7
        case .f3: return kVK_F3
        case .f8: return kVK_F8
        case .f9: return kVK_F9
        case .f11: return kVK_F11
        case .f13: return kVK_F13
        case .f16: return kVK_F16
        case .f14: return kVK_F14
        case .f10: return kVK_F10
        case .f12: return kVK_F12
        case .f15: return kVK_F15
        case .help: return kVK_Help
        case .home: return kVK_Home
        case .pageUp: return kVK_PageUp
        case .forwardDelete: return kVK_ForwardDelete
        case .f4: return kVK_F4
        case .end: return kVK_End
        case .f2: return kVK_F2
        case .pageDown: return kVK_PageDown
        case .f1: return kVK_F1
        case .leftArrow: return kVK_LeftArrow
        case .rightArrow: return kVK_RightArrow
        case .downArrow: return kVK_DownArrow
        case .upArrow: return kVK_UpArrow
        }
    }
}

extension Key: CustomStringConvertible {
    public var description: String {
        switch  self {
        case .a: return "A"
        case .s: return "S"
        case .d: return "D"
        case .f: return "F"
        case .h: return "H"
        case .g: return "G"
        case .z: return "Z"
        case .x: return "X"
        case .c: return "C"
        case .v: return "V"
        case .b: return "B"
        case .q: return "Q"
        case .w: return "W"
        case .e: return "E"
        case .r: return "R"
        case .y: return "Y"
        case .t: return "T"
        case .one, .keypad1: return "1"
        case .two, .keypad2: return "2"
        case .three, .keypad3: return "3"
        case .four, .keypad4: return "4"
        case .six, .keypad6: return "6"
        case .five, .keypad5: return "5"
        case .equal: return "="
        case .nine, .keypad9: return "9"
        case .seven, .keypad7: return "7"
        case .minus: return "-"
        case .eight, .keypad8: return "8"
        case .zero, .keypad0: return "0"
        case .rightBracket: return "]"
        case .o: return "O"
        case .u: return "U"
        case .leftBracket: return "["
        case .i: return "I"
        case .p: return "P"
        case .l: return "L"
        case .j: return "J"
        case .quote: return "\""
        case .k: return "K"
        case .semicolon: return ";"
        case .backslash: return "\\"
        case .comma: return ","
        case .slash: return "/"
        case .n: return "N"
        case .m: return "M"
        case .period: return "."
        case .grave: return "`"
        case .keypadDecimal: return "."
        case .keypadMultiply: return "𝗑"
        case .keypadPlus: return "+"
        case .keypadClear: return "⌧"
        case .keypadDivide: return "/"
        case .keypadEnter: return "↩︎"
        case .keypadMinus: return "-"
        case .keypadEquals: return "="
        case .`return`: return "↩︎"
        case .tab: return "⇥"
        case .space: return "␣"
        case .delete: return "⌫"
        case .escape: return "⎋"
        case .command, .rightCommand: return "⌘"
        case .shift, .rightShift: return "⇧"
        case .capsLock: return "⇪"
        case .option, .rightOption: return "⌥"
        case .control, .rightControl: return "⌃"
        case .function: return "fn"
        case .f17: return "F17"
        case .volumeUp: return "🔊"
        case .volumeDown: return "🔉"
        case .mute: return "🔇"
        case .f18: return "F18"
        case .f19: return "F19"
        case .f20: return "F20"
        case .f5: return "F5"
        case .f6: return "F6"
        case .f7: return "F7"
        case .f3: return "F3"
        case .f8: return "F8"
        case .f9: return "F9"
        case .f11: return "F11"
        case .f13: return "F13"
        case .f16: return "F16"
        case .f14: return "F14"
        case .f10: return "F10"
        case .f12: return "F12"
        case .f15: return "F15"
        case .help: return "?⃝"
        case .home: return "↖"
        case .pageUp: return "⇞"
        case .forwardDelete: return "⌦"
        case .f4: return "F4"
        case .end: return "↘"
        case .f2: return "F2"
        case .pageDown: return "⇟"
        case .f1: return "F1"
        case .leftArrow: return "←"
        case .rightArrow: return "→"
        case .downArrow: return "↓"
        case .upArrow: return "↑"
        }
    }
}

