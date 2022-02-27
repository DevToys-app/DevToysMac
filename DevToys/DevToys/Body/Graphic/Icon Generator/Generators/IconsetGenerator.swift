//
//  IconsetGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil

enum IconsetGenerator {
    static func make(item: ImageItem, to destinationURL: URL) -> IconGenerateTask {
        IconGenerateTask(imageItem: item, complete: .tryAsync{
            try self.generateIconset(image: item.image, to: destinationURL)
        })
    }
    
    static func generateIconset(image: NSImage, to destinationURL: URL) throws {
        guard let s16 = image.resizedAspectFit(to: [16, 16], fillColor: .clear)?.png,
              let s32 = image.resizedAspectFit(to: [32, 32], fillColor: .clear)?.png,
              let s64 = image.resizedAspectFit(to: [64, 64], fillColor: .clear)?.png,
              let s128 = image.resizedAspectFit(to: [128, 128], fillColor: .clear)?.png,
              let s256 = image.resizedAspectFit(to: [256, 256], fillColor: .clear)?.png,
              let s512 = image.resizedAspectFit(to: [512, 512], fillColor: .clear)?.png,
              let s1024 = image.resizedAspectFit(to: [1024, 1024], fillColor: .clear)?.png
        else { throw IconGenerateError.convertError }
        
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try s16.write(to: destinationURL.appendingPathComponent("icon_16x16.png"))
            try s32.write(to: destinationURL.appendingPathComponent("icon_16x16@2x.png"))
            try s32.write(to: destinationURL.appendingPathComponent("icon_32x32.png"))
            try s64.write(to: destinationURL.appendingPathComponent("icon_32x32@2x.png"))
            try s128.write(to: destinationURL.appendingPathComponent("icon_128x128.png"))
            try s256.write(to: destinationURL.appendingPathComponent("icon_128x128@2x.png"))
            try s256.write(to: destinationURL.appendingPathComponent("icon_256x256.png"))
            try s512.write(to: destinationURL.appendingPathComponent("icon_256x256@2x.png"))
            try s512.write(to: destinationURL.appendingPathComponent("icon_512x512.png"))
            try s1024.write(to: destinationURL.appendingPathComponent("icon_512x512@2x.png"))
        } catch {
            throw IconGenerateError.exportError(error)
        }
        
        return ()
    }
}

