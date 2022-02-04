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
        
        if items.count == 1 {
            guard let image = NSImage(pasteboard: pasteboard) else { return [] }
            let imageName = (pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL])?.first?.lastPathComponent ?? "Image"
            newImageItems =  [ImageItem(title: imageName, image: image)]
        } else {
            guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else { return [] }
            let images = urls.compactMap{ url in
                NSImage(contentsOf: url).map{ ImageItem(title: url.lastPathComponent, image: $0) }
            }
            newImageItems = images
        }
        
        return newImageItems
    }
}
