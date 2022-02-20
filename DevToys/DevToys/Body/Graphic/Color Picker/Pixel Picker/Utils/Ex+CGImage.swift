//
//  CGImage.swift
//  Pixel Picker
//

import Cocoa

extension CGImage {
    func colorAt(x: Int, y: Int) -> NSColor {
        assert(0 <= x && x < self.width)
        assert(0 <= y && y < self.height)

        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(self.height)

        // Allocate memory for image data. This is the destination in memory where any drawing to
        // the bitmap context will be rendered.
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitmapData = malloc(bitmapByteCount)

        // Since we manually allocate memeory for the data, we must ensure that the same memory is
        // freed after we've used it.
        defer { free(bitmapData) }

        // Create the bitmap context.
        let context = CGContext(
            data: bitmapData,
            width: self.width,
            height: self.height,
            bitsPerComponent: 8,
            bytesPerRow: bitmapBytesPerRow,
            space: .current,
            bitmapInfo: bitmapInfo.rawValue
        )

        // Extract the pixel data from the right offset.
        if context != nil {
            // First, we draw the image data onto the context we created.
            let rect = CGRect(x: 0, y: 0, width: self.width, height: self.height)
            context!.draw(self, in: rect)

            // Then we extract the data at the right spot.
            let data = context!.data!
            let offset = 4 * (y * width + x)

            let a = CGFloat(data.load(fromByteOffset: offset, as: UInt8.self)) / 255.0
            let r = CGFloat(data.load(fromByteOffset: offset + 1, as: UInt8.self)) / 255.0
            let g = CGFloat(data.load(fromByteOffset: offset + 2, as: UInt8.self)) / 255.0
            let b = CGFloat(data.load(fromByteOffset: offset + 3, as: UInt8.self)) / 255.0
            
            return NSColor(red: r, green: g, blue: b, alpha: a)
        }

        // Creating the context failed, so return a default color instead.
        // Hopefully, this should never happen.

        return NSColor.black
    }
}
