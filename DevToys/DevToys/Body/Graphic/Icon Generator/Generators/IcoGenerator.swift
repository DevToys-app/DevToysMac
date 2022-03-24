//
//  IcoGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/28.
//

import CoreUtil


enum IcoGenerator {
    static func make(item: ImageItem, templete: IconTemplete, to destinationURL: URL) -> IconGenerateTask {
        let image = templete.bake(image: item.image, scale: .x256)
        
        let complete = Promise<URL, Error>.tryAsync{
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).png")
            try image.png?.write(to: tmpURL)
            return tmpURL
        }
        .flatPeek{ FFExecutor.execute([], inputURL: $0, destinationURL: destinationURL).eraseToError().flatMap{ $0.complete } }
        .tryPeek{ try FileManager.default.removeItem(at: $0) }
        .eraseToVoid()
        
        return IconGenerateTask(imageItem: item, complete: complete)
    }
}
