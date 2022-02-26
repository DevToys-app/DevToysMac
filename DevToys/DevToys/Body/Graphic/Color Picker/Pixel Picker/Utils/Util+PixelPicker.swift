//
//  Util.swift
//  Pixel Picker
//

import Cocoa

let APP_NAME = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
let APPLE_INTERFACE_STYLE = "AppleInterfaceStyle"

// Copies the given string to the clipboard.
func copyToPasteboard(stringValue value: String) {
    NSPasteboard.general.declareTypes([.string], owner: nil)
    NSPasteboard.general.setString(value, forType: .string)
}

// Ensure that the given number is odd.
func ensureOdd(_ x: CGFloat) -> CGFloat {
    if Int(x) % 2 == 0 { return x + 1 }
    return x
}

// Checks whether a float roughly ends in ".5".
func isHalf(_ x: CGFloat) -> Bool {
    return Int(x * 2) % 2 != 0
}

// The Cocoa APIs have a coordinate system (origin is top-left of the screen) but the
// Carbon/CoreGraphics APIs use an old coordinate system where the origin is the
// bottom-left corner *of the primary display*.
// The primary display is always the first item of the NSScreen.screens array.
func convertToCGCoordinateSystem(_ point: NSPoint) -> CGPoint {
    return CGPoint(x: point.x, y: NSScreen.screens[0].frame.size.height - point.y)
}

// Returns the screen which contains the mouse cursor.
func getScreenFromPoint(_ point: NSPoint) -> NSScreen? {
    return NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) }
}

// Checks if the given point is outside of the given rect.
// Returns which coordinates are outside, if any.
enum Coordinate {
    case x, y, both, none
    static func isOutsideRect(_ point: NSPoint, _ rect: NSRect) -> Coordinate {
        let x = point.x < rect.origin.x || point.x > (rect.origin.x + rect.width)
        let y = point.y < rect.origin.y || point.y > (rect.origin.y + rect.height)
        if x && y { return .both }
        if x { return .x }
        if y { return .y }
        return .none
    }
}

// A simple helper to run animations with the same context configration.
func runAnimation(_ f: (NSAnimationContext) -> Void, done: (() -> Void)?) {
    NSAnimationContext.runAnimationGroup({ context in
        context.duration = 0.5
        context.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        context.allowsImplicitAnimation = true
        f(context)
    }, completionHandler: done)
}

// Make menu bar images templates with 16x16 dimensions.
func setupMenuBarIcon(_ image: NSImage?) -> NSImage? {
    image?.isTemplate = true
    image?.size = NSSize(width: 16, height: 16)
    return image
}
