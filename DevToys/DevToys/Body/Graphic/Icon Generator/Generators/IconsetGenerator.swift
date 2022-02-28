//
//  IconsetGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil

enum IconsetGenerator {
    static func make(item: ImageItem, templete: IconTemplete, to destinationURL: URL) -> IconGenerateTask {
        IconGenerateTask(imageItem: item, complete: .tryAsync{
            try self.generateIconset(image: item.image, templete: templete, to: destinationURL)
        })
    }
    
    static func generateIconset(image: NSImage, templete: IconTemplete, to destinationURL: URL) throws {
        let iconset = templete.bakeIconSet(image: image)
        
        do {
            try iconset.write(to: destinationURL)
        } catch {
            throw IconGenerateError.exportError(error)
        }
        
        return ()
    }
}

