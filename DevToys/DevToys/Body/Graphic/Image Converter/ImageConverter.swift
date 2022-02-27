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
        
        let filename = "\(item.filenameWithoutExtension).\(format.exp)"
        let destinationURL = destinationDirectory.appendingPathComponent(filename)
        let isDone = exportPromise(image, to: format, destinationURL: destinationURL)
            .receive(on: .main)
            .peek{ NSWorkspace.shared.activateFileViewerSelecting([destinationURL]) }
        
        return ImageConvertTask(image: item.image, title: item.filename, size: item.image.size, destinationURL: destinationURL, isDone: isDone)
    }
    
    private static func exportPromise(_ image: NSImage, to format: ImageFormatType, destinationURL: URL) -> Promise<Void, Error> {
        switch format {
        case .webp: return WebpImageExporter.export(image, to: destinationURL)
        case .heic: return HeicImageExporter.export(image, to: destinationURL)
        case .png: return DefaultImageExporter.exportPNG(image, to: destinationURL)
        case .jpg: return DefaultImageExporter.exportJPEG(image, to: destinationURL)
        case .gif: return DefaultImageExporter.exportGIF(image, to: destinationURL)
        case .tiff: return DefaultImageExporter.exportTIFF(image, to: destinationURL)
        }
    }    
}

enum ImageFormatType: String, TextItem {
    case png = "PNG Format"
    case jpg = "JPEG Format"
    case tiff = "TIFF Format"
    case gif = "GIF Format"
    case webp = "Webp Format"
    case heic = "Heic Format"
    
    var title: String { rawValue.localized() }
    
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

enum ImageScaleMode: String, TextItem {
    case scaleToFill = "Scale to Fill"
    case scaleToFit = "Scale to Fit"
    
    var title: String { rawValue.localized() }
}

extension NSImage {
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
    
    func resizedAspectFit(to newSize: CGSize, fillColor: NSColor = .black) -> NSImage? {
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else { return nil }
        
        let scale = self.size.aspectFitRatio(fitInside: newSize)
        
        bitmapRep.size = newSize
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        fillColor.setFill()
        NSRect(size: newSize).fill()
        draw(in: CGRect(center: newSize.convertToPoint()/2, size: self.size * scale), from: .zero, operation: .sourceOver, fraction: 1.0)
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
