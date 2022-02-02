//
//  Ex+NSEdgeInsets.swift
//  CoreUtil
//
//  Created by yuki on 2022/01/29.
//

import Cocoa

extension NSEdgeInsets: Equatable {
    public static let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        lhs.top == rhs.top && lhs.left == rhs.left && lhs.bottom == rhs.bottom && lhs.right == rhs.right
    }
    
    public static func each(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> NSEdgeInsets {
        NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    public init(repeating element: CGFloat) {
        self.init(top: element, left: element, bottom: element, right: element)
    }
    
    public init(x: CGFloat=0, y: CGFloat=0) {
        self.init(top: y, left: x, bottom: y, right: x)
    }
}
