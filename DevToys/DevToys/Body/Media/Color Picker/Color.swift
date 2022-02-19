//
//  Color.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

struct Color {
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
    
    var nsColor: NSColor { NSColor(colorSpace: .current, hue: hue, saturation: saturation, brightness: brightness, alpha: alpha) }
    var cgColor: CGColor { nsColor.cgColor }
}


extension Color {
    static let `default` = Color(hue: 0, saturation: 1, brightness: 1, alpha: 1)
}
