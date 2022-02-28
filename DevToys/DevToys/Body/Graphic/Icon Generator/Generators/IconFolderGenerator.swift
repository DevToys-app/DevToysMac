//
//  IconFolderGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil
import CoreGraphics

enum IconFolderGenerator {
    static func make(item: ImageItem, templete: IconTemplete, to destinationURL: URL) -> IconGenerateTask {
        IconGenerateTask(imageItem: item, complete: .tryAsync{
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            let image = templete.bake(image: item.image, scale: .x1024)
            NSWorkspace.shared.setIcon(image, forFile: destinationURL.path, options: .excludeQuickDrawElementsIconCreationOption)
        })
    }
}
