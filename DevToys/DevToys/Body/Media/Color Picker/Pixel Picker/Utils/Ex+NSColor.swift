//
//  NSColor.swift
//  Pixel Picker
//

import Cocoa

extension NSColor {
    func image(withSize size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        self.set()
        NSRect(origin: NSPoint.zero, size: size).fill()
        image.unlockFocus()
        return image
    }

    func bestContrastingColor() -> NSColor {
        let rgb: [CGFloat] = [self.redComponent, self.greenComponent, self.blueComponent].map({
            if $0 <= 0.03928 {
                return $0 / 12.92
            } else {
                return pow(($0 + 0.055) / 1.055, 2.4)
            }
        })

        let L = 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]
        return L > 0.197 ? NSColor.black : NSColor.white
    }
}
