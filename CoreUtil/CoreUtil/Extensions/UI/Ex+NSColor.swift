import Cocoa

// MARK: - Extension for Color
extension NSColor {
    public convenience init(colorSpace: NSColorSpace = .current, hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xff_00_00) >> 16) / 255
        let green = CGFloat((hex & 0x00_ff_00) >> 8) / 255
        let blue = CGFloat((hex & 0x00_00_ff) >> 0) / 255

        self.init(colorSpace: colorSpace, red: red, green: green, blue: blue, alpha: alpha)
    }

    public convenience init(colorSpace: NSColorSpace = .current, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var rgba = [red, green, blue, alpha]
        self.init(colorSpace: colorSpace, components: &rgba, count: rgba.count)
    }
}

extension NSColorSpace {
    public static let current: NSColorSpace = NSScreen.main?.colorSpace ?? NSColorSpace.deviceRGB
}

extension CGColorSpace {
    public static let current: CGColorSpace = NSColorSpace.current.cgColorSpace ?? CGColorSpaceCreateDeviceRGB()
}
