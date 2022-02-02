//
//  NSColorView.swift
//  CoreUtil
//
//  Created by yuki on 2021/10/05.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa

open class NSColorView: NSLoadView {
    open var borderWidth: CGFloat = 1 { didSet { setNeedsDisplay(bounds) } }
    open var borderColor: NSColor? { didSet { setNeedsDisplay(bounds) } }
    open var backgroundColor: NSColor? { didSet { setNeedsDisplay(bounds) } }
    
    open override func draw(_ dirtyRect: NSRect) {
        if let backgroundColor = self.backgroundColor {
            backgroundColor.setFill()
            dirtyRect.fill()
        }
        if let borderColor = self.borderColor {
            borderColor.setStroke()
            let path = NSBezierPath(rect: dirtyRect)
            path.lineWidth = borderWidth
            path.stroke()
        }
    }
}
