//
//  PNGGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/28.
//

import Foundation

enum PngIconGenerator {
    static func make(item: ImageItem, templete: IconTemplete, scale: IconSet.Scale, to destinationURL: URL) -> IconGenerateTask {
        IconGenerateTask(imageItem: item, complete: .tryAsync{
            try templete.bake(image: item.image, scale: scale).png?.write(to: destinationURL)
        })
    }
}

enum JpegIconGenerator {
    static func make(item: ImageItem, templete: IconTemplete, scale: IconSet.Scale, to destinationURL: URL) -> IconGenerateTask {
        IconGenerateTask(imageItem: item, complete: .tryAsync{
            try templete.bake(image: item.image, scale: scale).jpeg?.write(to: destinationURL)
        })
    }
}

enum GifIconGenerator {
    static func make(item: ImageItem, templete: IconTemplete, scale: IconSet.Scale, to destinationURL: URL) -> IconGenerateTask {
        IconGenerateTask(imageItem: item, complete: .tryAsync{
            try templete.bake(image: item.image, scale: scale).gif?.write(to: destinationURL)
        })
    }
}
