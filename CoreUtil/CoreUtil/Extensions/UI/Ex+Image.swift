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


extension CGImage {
    public func convertToGrayscale() -> CGImage {
        let imageRect = CGRect(size: CGSize(width: width, height: height))
        let context = CGContext(
            data: nil, width: self.width, height: self.height,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        context.draw(self, in: imageRect)
        return context.makeImage()!
    }
}
