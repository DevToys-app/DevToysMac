//
//  DefaultImageExporter.swift
//  DevToys
//
//  Created by yuki on 2022/02/18.
//

import CoreUtil

enum ImageExportError: Error {
    case nonData
}

enum DefaultImageExporter {
    static func exportPNG(_ image: NSImage, to url: URL) -> Promise<Void, Error> {
        .tryAsync {
            guard let data = image.png else { throw ImageExportError.nonData }
            try data.write(to: url)
        }
    }
    static func exportGIF(_ image: NSImage, to url: URL) -> Promise<Void, Error> {
        .tryAsync {
            guard let data = image.gif else { throw ImageExportError.nonData }
            try data.write(to: url)
        }
    }
    static func exportJPEG(_ image: NSImage, to url: URL) -> Promise<Void, Error> {
        .tryAsync {
            guard let data = image.jpeg else { throw ImageExportError.nonData }
            try data.write(to: url)
        }
    }
    static func exportTIFF(_ image: NSImage, to url: URL) -> Promise<Void, Error> {
        .tryAsync {
            guard let data = image.tiffRepresentation else { throw ImageExportError.nonData }
            try data.write(to: url)
        }
    }
}


extension NSImage {
    public var png: Data? { self.data(for: .png) }
    public var jpeg: Data? {  self.data(for: .jpeg) }
    public var gif: Data? {  self.data(for: .gif)  }
    
    public convenience init(cgImage: CGImage) { self.init(cgImage: cgImage, size: cgImage.size) }
    
    public func data(for fileType: NSBitmapImageRep.FileType, properties: [NSBitmapImageRep.PropertyKey : Any] = [:]) -> Data? {
        guard
            let tiffRepresentation = self.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffRepresentation),
            let rep = bitmap.representation(using: fileType, properties: properties)
        else { return nil }
        
        return rep
    }
}

extension CGImage {
    public var size: CGSize { CGSize(width: self.width, height: self.height) }
}
