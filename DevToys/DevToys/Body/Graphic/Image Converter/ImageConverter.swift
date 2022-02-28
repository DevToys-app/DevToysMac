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
            case .scaleToFill: image = image.resizedAspectFill(to: size)
            case .scaleToFit: image = image.resizedAspectFit(to: size)
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
    func resizedAspectFill(to newSize: CGSize) -> NSImage {
        let bitmapRep = NSBitmapImageRep(size: newSize)
        let scale = self.size.aspectFillRatio(fillInside: newSize)
        
        NSGraphicsContext(bitmapImageRep: bitmapRep)?.perform {
            self.draw(in: CGRect(center: newSize.convertToPoint()/2, size: self.size * scale), from: .zero, operation: .copy, fraction: 1.0)
        }
        
        return NSImage(bitmapImageRep: bitmapRep)
    }
    
    func resizedAspectFit(to newSize: CGSize, fillColor: NSColor = .black) -> NSImage {
        let bitmapRep = NSBitmapImageRep(size: newSize)
        let scale = self.size.aspectFitRatio(fitInside: newSize)
        
        NSGraphicsContext(bitmapImageRep: bitmapRep)?.perform {
            fillColor.setFill()
            NSRect(size: newSize).fill()
            draw(in: CGRect(center: newSize.convertToPoint()/2, size: self.size * scale), from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        
        return NSImage(bitmapImageRep: bitmapRep)
    }
    
    
    func resized(to newSize: NSSize) -> NSImage {
        let bitmapRep = NSBitmapImageRep(size: newSize)
        
        NSGraphicsContext(bitmapImageRep: bitmapRep)?.perform {
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
        }
        
        return NSImage(bitmapImageRep: bitmapRep)
    }
}

extension NSGraphicsContext {
    public func perform(_ block: () -> ()) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = self
        block()
        NSGraphicsContext.restoreGraphicsState()
    }
}

extension NSImage {
    public convenience init(bitmapImageRep: NSBitmapImageRep) {
        self.init(size: bitmapImageRep.size)
        self.addRepresentation(bitmapImageRep)
    }
    public convenience init(size: CGSize, colorSpaceName: NSColorSpaceName = .calibratedRGB, canvas: () -> ()) {
        let bitmapImageRep = NSBitmapImageRep(size: size, colorSpaceName: colorSpaceName)
        NSGraphicsContext(bitmapImageRep: bitmapImageRep)?.perform(canvas)
        self.init(bitmapImageRep: bitmapImageRep)
    }
    public convenience init(size: CGSize, colorSpaceName: NSColorSpaceName = .calibratedRGB, cgcanvas: (CGContext) -> ()) {
        self.init(size: size, colorSpaceName: colorSpaceName, canvas: {
            if let context = NSGraphicsContext.current?.cgContext { cgcanvas(context) }
        })
    }
}

extension NSBitmapImageRep {
    public convenience init(size: CGSize, colorSpaceName: NSColorSpaceName = .calibratedRGB) {
        self.init(
            bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: colorSpaceName, bytesPerRow: 0, bitsPerPixel: 0
        )!
    }
}


extension CGContext {
    public var size: CGSize { CGSize(width: width, height: height) }
    public var bounds: CGRect { CGRect(size: size) }
}
