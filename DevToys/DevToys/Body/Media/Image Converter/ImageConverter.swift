//
//  ImageConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/04.
//

import CoreUtil

struct ImageConvertTask {
    let image: NSImage
    let title: String
    let size: CGSize
    let destinationURL: URL
    let isDone: Promise<Void, Error>
}

enum ImageConverter {
    private static let destinationDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)[0].appendingPathComponent("DevToys") => {
        try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func convert(_ item: ImageItem, format: ImageFormatType, resize: Bool, size: CGSize, scale: ImageScaleMode) -> ImageConvertTask {
        var image = item.image
        
        if resize {
            switch scale {
            case .scaleToFill: if let rimage = image.resizedAspectFill(to: size) { image = rimage }
            case .scaleToFit: if let rimage = image.resizedAspectFit(to: size) { image = rimage }
            }
        }
        
        let filename = "\(item.title.split(separator: ".").dropLast().joined(separator: ".")).\(format.exp)"
        let destinationURL = destinationDirectory.appendingPathComponent(filename)
        
        let isDone: Promise<Void, Error>
        
        switch format {
        case .webp:
            isDone = WebpConvertrer.convert(image, to: destinationURL).eraseToVoid()
        case .heic:
            isDone = HeicConverter.export(image, to: destinationURL)
        case .png, .jpg, .tiff, .gif:
            isDone = exportNonWebp(image, to: format, to: destinationURL)
        }
        
        return ImageConvertTask(
            image: item.image, title: item.title, size: item.image.size, destinationURL: destinationURL,
            isDone:
                isDone
                .receive(on: .main)
                .peek{ NSWorkspace.shared.activateFileViewerSelecting([destinationURL]) }
        )
    }
    
    
    private static func exportNonWebp(_ image: NSImage, to format: ImageFormatType, to url: URL) -> Promise<Void, Error> {
        Promise(output: { () throws -> Data in
            switch format {
            case .png:
                guard let data = image.png else { throw "Data failed." }; return data
            case .jpg:
                guard let data = image.jpeg else { throw "Data failed." }; return data
            case .tiff:
                guard let data = image.tiffRepresentation else { throw "Data failed." }; return data
            case .gif:
                guard let data = image.gif else { throw "Data failed." }; return data
            default:
                assertionFailure("Format not supported!")
                return Data()
            }
        })
        .tryPeek{ try $0.write(to: url) }
        .eraseToVoid()
    }
}

extension ImageFormatType {
    var exp: String {
        switch self {
        case .png: return "png"
        case .jpg: return "jpg"
        case .gif: return "gif"
        case .tiff: return "tiff"
        case .webp: return "webp"
        case .heic: return "heic"
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


extension NSImage {
    var pngData: Data { png! }
    
    func resizedAspectFill(to newSize: CGSize) -> NSImage? {
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else { return nil }
        let scale = self.size.aspectFillRatio(fillInside: newSize)
        
        bitmapRep.size = newSize
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        self.draw(in: CGRect(center: newSize.convertToPoint()/2, size: self.size * scale), from: .zero, operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.addRepresentation(bitmapRep)
        return resizedImage
    }
    
    func resizedAspectFit(to newSize: CGSize) -> NSImage? {
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else { return nil }
        
        let scale = self.size.aspectFitRatio(fitInside: newSize)
        
        bitmapRep.size = newSize
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        NSColor.black.setFill()
        NSRect(size: newSize).fill()
        draw(in: CGRect(center: newSize.convertToPoint()/2, size: self.size * scale), from: .zero, operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.addRepresentation(bitmapRep)
        return resizedImage
    }
    
    
    func resized(to newSize: NSSize) -> NSImage {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }

        fatalError()
    }
}
