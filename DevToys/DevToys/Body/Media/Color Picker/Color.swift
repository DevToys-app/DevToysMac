//
//  Color.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

struct Color: Codable {
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
    
    var rgb: (CGFloat, CGFloat, CGFloat) {
        let nsColor = self.nsColor
        return (nsColor.redComponent, nsColor.greenComponent, nsColor.blueComponent)
    }
    var cmyk: (cyan: CGFloat, magenta: CGFloat, yellow: CGFloat, black:CGFloat) {
        let (r, g, b) = self.rgb

        let k = 1.0 - max(r, g, b)
        var c = (1.0 - r - k) / (1.0 - k)
        var m = (1.0 - g - k) / (1.0 - k)
        var y = (1.0 - b - k) / (1.0 - k)

        if c.isNaN { c = 0.0 }
        if m.isNaN { m = 0.0 }
        if y.isNaN { y = 0.0 }

        return (cyan: c, magenta: m, yellow: y, black: k)
    }
    
    
    var nsColor: NSColor { NSColor(colorSpace: .current, hue: hue, saturation: saturation, brightness: brightness, alpha: alpha) }
    var cgColor: CGColor { nsColor.cgColor }
}


extension Color {
    static let `default` = Color(hue: 0, saturation: 1, brightness: 1, alpha: 1)
}
