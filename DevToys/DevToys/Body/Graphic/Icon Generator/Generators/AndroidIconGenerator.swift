//
//  AndroidIconGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/27.
//

import CoreUtil

enum AndroidIconGenerator {
    static func make(item: ImageItem, templete: IconTemplete, to destinationURL: URL) -> IconGenerateTask {
        let image = templete.bake(image: item.image, scale: .x512) 
        
        let complete = Promise<Void, Error>.tryAsync{
            guard
                let s48 = image.resizedAspectFit(to: [48, 48], fillColor: .clear).png,
                let s72 = image.resizedAspectFit(to: [72, 72], fillColor: .clear).png,
                let s96 = image.resizedAspectFit(to: [96, 96], fillColor: .clear).png,
                let s144 = image.resizedAspectFit(to: [144, 144], fillColor: .clear).png,
                let s192 = image.resizedAspectFit(to: [192, 192], fillColor: .clear).png,
                let s512 = image.resizedAspectFit(to: [512, 512], fillColor: .clear).png
            else { throw IconGenerateError.convertError }
            
            do {
                try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                
                try s48.write(to: destinationURL.appendingPathComponent("icon_mdpi.png"))
                try s72.write(to: destinationURL.appendingPathComponent("icon_hdpi.png"))
                try s96.write(to: destinationURL.appendingPathComponent("icon_xhdpi.png"))
                try s144.write(to: destinationURL.appendingPathComponent("icon_xxhdpi.png"))
                try s192.write(to: destinationURL.appendingPathComponent("icon_xxxhdpi.png"))
                try s512.write(to: destinationURL.appendingPathComponent("play_store.png"))
            } catch {
                throw IconGenerateError.exportError(error)
            }
        }
            
        return .init(imageItem: item, complete: complete)
    }
}
