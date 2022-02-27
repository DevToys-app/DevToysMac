//
//  IconFolderGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil

enum IconFolderGenerator {
    static func make(item: ImageItem, to destinationURL: URL) -> IconGenerateTask {
        IconGenerateTask(imageItem: item, complete: .tryAsync{
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            NSWorkspace.shared.setIcon(item.image, forFile: destinationURL.path)
        })
    }
}
