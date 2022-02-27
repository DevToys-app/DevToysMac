//
//  ImageDropper.swift
//  DevToys
//
//  Created by yuki on 2022/02/04.
//

import Cocoa

enum ImageDropper {
    static func images(fromPasteboard pasteboard: NSPasteboard) -> [ImageItem] {
        var newImageItems = [ImageItem]()
        guard let items = pasteboard.pasteboardItems else { return [] }
        
        if items.count == 1, let url = (pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL])?.first {
            guard let image = NSImage(pasteboard: pasteboard) else { return [] }
            newImageItems = [ImageItem(fileURL: url, image: image)]
        } else {
            guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else { return [] }
            let images = urls.compactMap{ url in
                NSImage(contentsOf: url).map{ ImageItem(fileURL: url, image: $0) }
            }
            newImageItems = images
        }
        
        return newImageItems
    }
}
