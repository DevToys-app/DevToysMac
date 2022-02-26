//
//  FFThumnailGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/21.
//

import CoreUtil

enum FFThumnailGenerator {
    private static let thumbnmailURL = FileManager.temporaryDirectoryURL.appendingPathExtension("FFThumbnail") => {
        try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func thumbnail(of movieURL: URL, size: CGSize) -> Promise<NSImage?, Never> {
        let filename = UUID().uuidString + ".jpg"
        let thumbURL = self.thumbnmailURL.appendingPathComponent(filename)
        
        let task = FFExecutor.execute([
            "-vframes", "1",
            "-f", "image2",
            "-vf", "scale=\(size.width):\(size.height):force_original_aspect_ratio=decrease"
        ], inputURL: movieURL, destinationURL: thumbURL)
        
        return task.eraseToError().flatMap{ $0.complete }
            .map{ NSImage(contentsOf: thumbURL) }
            .replaceError(with: nil)
    }
}
