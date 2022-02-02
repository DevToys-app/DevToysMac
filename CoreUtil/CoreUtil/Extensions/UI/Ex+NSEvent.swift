//
//  NSEvent+Location.swift
//  CoreUtil
//
//  Created by yuki on 2021/11/11.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa

extension NSEvent {
    @inlinable public func location(in view: NSView) -> CGPoint {
        view.convert(self.locationInWindow, from: nil)
    }
}
