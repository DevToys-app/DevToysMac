//
//  IcnsGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil

enum IcnsGenerator {
    private static let iconutilURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    private static let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("IcnsGenerator") => {
        try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func make(item: ImageItem, to destinationURL: URL) -> IconGenerateTask {
        let complete = Promise<URL, Error>
            .tryAsync{
                let iconsetURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("iconset")
                try IconsetGenerator.generateIconset(image: item.image, to: iconsetURL)
                return iconsetURL
            }
            .flatPeek{ Terminal.run(iconutilURL, arguments: ["-c", "icns", "--output", destinationURL.path, $0.path]) }
            .tryPeek{ try FileManager.default.removeItem(at: $0) }
            .eraseToVoid()
        
        return IconGenerateTask(imageItem: item, complete: complete)
    }
}
