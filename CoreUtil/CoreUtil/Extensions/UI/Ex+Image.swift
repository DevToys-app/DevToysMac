//
//  Ex+Image.swift
//  CoreUtil
//
//  Created by yuki on 2020/03/10.
//  Copyright © 2020 yuki. All rights reserved.
//

import Cocoa

extension NSImage {
    public var cgImage: CGImage? {
        var imageRect = CGRect(size: self.size)
        return cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
    }
}
