import Cocoa

public let NSOutlineViewNotificationItemKey = "NSObject"

extension NSView {
    #if DEBUG
    public func __setBackgroundColor(_ color: NSColor) {
        self.wantsLayer = true
        self.layer?.backgroundColor = color.cgColor
    }
    #endif
}
