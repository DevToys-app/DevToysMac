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
    let isDone: Promise<Void, Error>
}

enum ImageConverter {
    private static let destinationDirectory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0].appendingPathComponent("Converted Images") => {
        try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func convert(_ item: ImageItem, format: ImageFormatType, resize: Bool, size: CGSize, scale: ImageScaleMode, padding: Bool) -> ImageConvertTask {
        var resizeSize = item.image.size
        if resize {
//            switch scale {
//            case <#pattern#>:
//                <#code#>
//            default:
//                <#code#>
//            }
        }
        
//        item.image.resized(to: <#T##NSSize#>)
        let isDone = Promise<Data, Error>.asyncError{ resolve, reject in
            switch format {
            case .png:
                guard let data = item.image.png else { return reject("Data failed.") }; resolve(data)
            case .jpg:
                guard let data = item.image.jpeg else { return reject("Data failed.") }; resolve(data)
            case .tiff:
                guard let data = item.image.tiffRepresentation else { return reject("Data failed.") }; resolve(data)
            case .gif:
                guard let data = item.image.gif else { return reject("Data failed.") }; resolve(data)
            }
        }
        .tryPeek{ data in
            let url = destinationDirectory.appendingPathComponent("\(item.title).\(format.exp)")
            try data.write(to: url)
        }
        .receive(on: .main)
        .eraseToVoid()
        
        return ImageConvertTask(image: item.image, title: item.title, size: item.image.size, isDone: isDone)
    }
}

extension ImageFormatType {
    var exp: String {
        switch self {
        case .png: return "png"
        case .jpg: return "jpg"
        case .gif: return "gif"
        case .tiff: return "tiff"
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

extension Promise {
    public func tryPeek(_ receiveOutput: @escaping (Output) throws -> ()) -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            self.sink({ output in
                do { try receiveOutput(output); resolve(output) } catch { reject(error) }
            }, reject)
        }
    }
}

extension NSImage {
    var pngData: Data { png! }
    
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
