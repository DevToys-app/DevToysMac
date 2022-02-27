//
//  IcnsGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil

enum IOSIconGenerator {
    struct ExportOptions: OptionSet {
        let rawValue: UInt64
        
        static let iphone = ExportOptions(rawValue: 1 << 0)
        static let ipad = ExportOptions(rawValue: 1 << 1)
        static let carplay = ExportOptions(rawValue: 1 << 2)
        static let mac = ExportOptions(rawValue: 1 << 3)
        static let applewatch = ExportOptions(rawValue: 1 << 4)
    }
    
    static func make(item: ImageItem, options: ExportOptions, to destinationURL: URL) -> IconGenerateTask {
        let complete = Promise<Void, Error>.tryAsync{
            let image = item.image
            let fillColor = NSColor.black
            
            guard
                let s16 = image.resizedAspectFit(to: [16, 16], fillColor: fillColor)?.png,
                let s20 = image.resizedAspectFit(to: [20, 20], fillColor: fillColor)?.png,
                let s29 = image.resizedAspectFit(to: [29, 29], fillColor: fillColor)?.png,
                let s32 = image.resizedAspectFit(to: [32, 32], fillColor: fillColor)?.png,
                let s40 = image.resizedAspectFit(to: [40, 40], fillColor: fillColor)?.png,
                let s48 = image.resizedAspectFit(to: [48, 48], fillColor: fillColor)?.png,
                let s55 = image.resizedAspectFit(to: [55, 55], fillColor: fillColor)?.png,
                let s57 = image.resizedAspectFit(to: [57, 57], fillColor: fillColor)?.png,
                let s58 = image.resizedAspectFit(to: [58, 58], fillColor: fillColor)?.png,
                let s60 = image.resizedAspectFit(to: [60, 60], fillColor: fillColor)?.png,
                let s64 = image.resizedAspectFit(to: [64, 64], fillColor: fillColor)?.png,
                let s66 = image.resizedAspectFit(to: [66, 66], fillColor: fillColor)?.png,
                let s76 = image.resizedAspectFit(to: [76, 76], fillColor: fillColor)?.png,
                let s80 = image.resizedAspectFit(to: [80, 80], fillColor: fillColor)?.png,
                let s87 = image.resizedAspectFit(to: [87, 87], fillColor: fillColor)?.png,
                let s88 = image.resizedAspectFit(to: [88, 88], fillColor: fillColor)?.png,
                let s92 = image.resizedAspectFit(to: [92, 92], fillColor: fillColor)?.png,
                let s100 = image.resizedAspectFit(to: [100, 100], fillColor: fillColor)?.png,
                let s102 = image.resizedAspectFit(to: [102, 102], fillColor: fillColor)?.png,
                let s114 = image.resizedAspectFit(to: [114, 114], fillColor: fillColor)?.png,
                let s120 = image.resizedAspectFit(to: [120, 120], fillColor: fillColor)?.png,
                let s128 = image.resizedAspectFit(to: [128, 128], fillColor: fillColor)?.png,
                let s152 = image.resizedAspectFit(to: [152, 152], fillColor: fillColor)?.png,
                let s167 = image.resizedAspectFit(to: [167, 167], fillColor: fillColor)?.png,
                let s172 = image.resizedAspectFit(to: [172, 172], fillColor: fillColor)?.png,
                let s180 = image.resizedAspectFit(to: [180, 180], fillColor: fillColor)?.png,
                let s196 = image.resizedAspectFit(to: [196, 196], fillColor: fillColor)?.png,
                let s216 = image.resizedAspectFit(to: [216, 216], fillColor: fillColor)?.png,
                let s234 = image.resizedAspectFit(to: [234, 234], fillColor: fillColor)?.png,
                let s256 = image.resizedAspectFit(to: [256, 256], fillColor: fillColor)?.png,
                let s512 = image.resizedAspectFit(to: [512, 512], fillColor: fillColor)?.png,
                let s1024 = image.resizedAspectFit(to: [1024, 1024], fillColor: fillColor)?.png
            else { throw IconGenerateError.convertError }
            
            do {
                try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                
                if options.contains(.iphone) {
                    try s40.write(to: destinationURL.appendingPathComponent("iPhone Notification@2x.png"))
                    try s60.write(to: destinationURL.appendingPathComponent("iPhone Notification@3x.png"))
                    
                    try s29.write(to: destinationURL.appendingPathComponent("iPhone Settings.png"))
                    try s58.write(to: destinationURL.appendingPathComponent("iPhone Settings@2x.png"))
                    try s87.write(to: destinationURL.appendingPathComponent("iPhone Settings@3x.png"))
                    
                    try s80.write(to: destinationURL.appendingPathComponent("iPhone Spotlight@2x.png"))
                    try s120.write(to: destinationURL.appendingPathComponent("iPhone Spotlight@3x.png"))
                    
                    try s57.write(to: destinationURL.appendingPathComponent("iPhone App iOS 5,6.png"))
                    try s114.write(to: destinationURL.appendingPathComponent("iPhone App iOS 5,6@2x.png"))
                    
                    try s120.write(to: destinationURL.appendingPathComponent("iPhone App@2x.png"))
                    try s180.write(to: destinationURL.appendingPathComponent("iPhone App@3x.png"))
                }
                
                if options.contains(.ipad) {
                    try s20.write(to: destinationURL.appendingPathComponent("iPad Notification.png"))
                    try s40.write(to: destinationURL.appendingPathComponent("iPad Notification@2x.png"))
                    
                    try s29.write(to: destinationURL.appendingPathComponent("iPad Settings.png"))
                    try s58.write(to: destinationURL.appendingPathComponent("iPad Settings@2x.png"))
                    
                    try s40.write(to: destinationURL.appendingPathComponent("iPad Spotlight.png"))
                    try s80.write(to: destinationURL.appendingPathComponent("iPad Spotlight@2x.png"))
                    
                    try s76.write(to: destinationURL.appendingPathComponent("iPad App.png"))
                    try s152.write(to: destinationURL.appendingPathComponent("iPad App@2x.png"))
                    
                    try s167.write(to: destinationURL.appendingPathComponent("iPad Pro App@2x.png"))
                }
                
                if options.contains(.iphone) || options.contains(.ipad) {
                    try s1024.write(to: destinationURL.appendingPathComponent("App Store iOS.png"))
                }
                
                if options.contains(.carplay) {
                    try s120.write(to: destinationURL.appendingPathComponent("CarPlay@2x.png"))
                    try s180.write(to: destinationURL.appendingPathComponent("CarPlay@3x.png"))
                }
                
                if options.contains(.mac) {
                    try s16.write(to: destinationURL.appendingPathComponent("Mac 16x16.png"))
                    try s32.write(to: destinationURL.appendingPathComponent("Mac 16x16@2x.png"))
                    
                    try s32.write(to: destinationURL.appendingPathComponent("Mac 32x32.png"))
                    try s64.write(to: destinationURL.appendingPathComponent("Mac 32x32@2x.png"))
                    
                    try s128.write(to: destinationURL.appendingPathComponent("Mac 128x128.png"))
                    try s256.write(to: destinationURL.appendingPathComponent("Mac 128x128@2x.png"))
                    
                    try s256.write(to: destinationURL.appendingPathComponent("Mac 256x256.png"))
                    try s512.write(to: destinationURL.appendingPathComponent("Mac 256x256@2x.png"))
                    
                    try s512.write(to: destinationURL.appendingPathComponent("Mac 512x512.png"))
                    try s1024.write(to: destinationURL.appendingPathComponent("Mac 512x512@2x.png"))
                }
                
                if options.contains(.applewatch) {
                    try s48.write(to: destinationURL.appendingPathComponent("Apple Watch Notification Center 48x28@2x.png"))
                    try s55.write(to: destinationURL.appendingPathComponent("Apple Watch Notification Center 55x55@2x.png"))
                    try s66.write(to: destinationURL.appendingPathComponent("Apple Watch Notification Center 66x66@2x.png"))
                    
                    try s58.write(to: destinationURL.appendingPathComponent("Apple Watch Companion Settings@2x.png"))
                    try s87.write(to: destinationURL.appendingPathComponent("Apple Watch Companion Settings@3x.png"))
                    
                    try s80.write(to: destinationURL.appendingPathComponent("Apple Watch Home Screen 38mm@2x.png"))
                    try s88.write(to: destinationURL.appendingPathComponent("Apple Watch Home Screen 40mm@2x.png"))
                    try s92.write(to: destinationURL.appendingPathComponent("Apple Watch Home Screen 41mm@2x.png"))
                    try s100.write(to: destinationURL.appendingPathComponent("Apple Watch Home Screen 44mm@2x.png"))
                    try s102.write(to: destinationURL.appendingPathComponent("Apple Watch Home Screen 45mm@2x.png"))
                    
                    try s172.write(to: destinationURL.appendingPathComponent("Apple Watch Short Look 172x172@2x.png"))
                    try s196.write(to: destinationURL.appendingPathComponent("Apple Watch Short Look 196x196@2x.png"))
                    try s216.write(to: destinationURL.appendingPathComponent("Apple Watch Short Look 216x216@2x.png"))
                    try s234.write(to: destinationURL.appendingPathComponent("Apple Watch Short Look 234x234@2x.png"))
                    
                    try s1024.write(to: destinationURL.appendingPathComponent("Apple Watch App Store.png"))
                }
                
            } catch {
                throw IconGenerateError.exportError(error)
            }
        }
        
        return .init(imageItem: item, complete: complete)
    }
}
