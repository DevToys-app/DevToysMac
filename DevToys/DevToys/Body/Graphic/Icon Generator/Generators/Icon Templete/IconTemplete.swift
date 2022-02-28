//
//  IconImageManager+.swift
//  DevToys
//
//  Created by yuki on 2022/02/27.
//

import CoreUtil

protocol IconTemplete {
    var title: String { get }
    var identifier: String { get }
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage
}

extension IconTemplete {
    func bakeIconSet(image: NSImage) -> IconSet {
        IconSet(make: { bake(image: image, scale: $0) })!
    }
}
