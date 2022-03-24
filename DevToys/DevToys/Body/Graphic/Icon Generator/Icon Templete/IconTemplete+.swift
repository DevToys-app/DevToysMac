//
//  FolderFillIconImage.swift
//  DevToys
//
//  Created by yuki on 2022/02/27.
//

import CoreUtil
import CoreGraphics

struct OriginalIconTemplete: IconTemplete {
    let title: String = "Original"
    let identifier: String = "original"
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage {
        return image.resizedAspectFit(to: [scale.size, scale.size], fillColor: .clear)
    }
}

struct RoundedRectIconTemplete: IconTemplete {
    let title: String = "Rounded"
    let identifier: String = "rounded"
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage {
        let size: CGSize = [scale.size, scale.size]
        
        let scaleFactor = scale.size / 1024
        return NSImage(size: size, cgcanvas: { context in
            let imageRect = CGRect(size: size).slimmed(by: 64 * scaleFactor)
            let image = IconTempleteHelper.fillToRect(rect: imageRect, image: image, size: size).cgImage!
            let cornerRadius = 64 * scaleFactor
            let circlePath = CGPath(roundedRect: imageRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
            context.saveGState()
            context.setFillColor(.white)
            context.addPath(circlePath)
            context.setShadow(offset: [0, -7] * scaleFactor, blur: 20 * scaleFactor, color: NSColor.black.withAlphaComponent(0.5).cgColor)
            context.fillPath()
            context.restoreGState()
            
            context.addPath(circlePath)
            context.clip()
            context.draw(image, in: context.bounds)
            context.resetClip()
        })
    }
}

struct CircleIconTemplete: IconTemplete {
    let title: String = "Circle"
    let identifier: String = "circle"
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage {
        let size: CGSize = [scale.size, scale.size]
        
        let scaleFactor = scale.size / 1024
        return NSImage(size: size, cgcanvas: { context in
            let imageRect = CGRect(size: size).slimmed(by: 64 * scaleFactor)
            let image = IconTempleteHelper.fillToRect(rect: imageRect, image: image, size: size).cgImage!
            let circlePath = CGPath(ellipseIn: imageRect, transform: nil)
            context.saveGState()
            context.setFillColor(.white)
            context.addPath(circlePath)
            context.setShadow(offset: [0, -7] * scaleFactor, blur: 20 * scaleFactor, color: NSColor.black.withAlphaComponent(0.5).cgColor)
            context.fillPath()
            context.restoreGState()
            
            context.addPath(circlePath)
            context.clip()
            context.draw(image, in: context.bounds)
            context.resetClip()
        })
    }
}

struct AndroidIconTemplete: IconTemplete {
    let title: String = "Android"
    let identifier: String = "android"
    
    private static let mask = IconSet(make: { Bundle.main.image(forResource: "android_mask.png")!.resized(to: [$0.size, $0.size]) })!
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage {
        let mask = Self.mask.image(for: scale)
        let size: CGSize = [scale.size, scale.size]
        return NSImage(size: size, cgcanvas: { context in
            let image = IconTempleteHelper.fillToRect(rect: CGRect(size: size), image: image, size: size).cgImage!
            
            context.clip(to: context.bounds, mask: mask.cgImage!.convertToGrayscale())
            context.setFillColor(.white)
            context.fill(context.bounds)
            context.draw(image, in: context.bounds)
        })
    }
}

struct BigSurFillIconTemplete: IconTemplete {
    let title: String = "Big Sur Icon"
    let identifier: String = "bigsur_icon"
    private static let background = IconSet(bundleResouces: { "squircle_back_\($0.point)x\($0.point).png" })!
    private static let mask = IconSet(bundleResouces: { "squircle_mask_\($0.point)x\($0.point).png" })!
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage {
        let background = Self.background.image(for: scale)
        let mask = Self.mask.image(for: scale)
        
        return NSImage(size: background.size, cgcanvas: { context in
            let image = IconTempleteHelper.fillToRect(rect: folderRect(scale), image: image, size: background.size).cgImage!
            
            context.draw(background.cgImage!, in: context.bounds)
            context.clip(to: context.bounds, mask: mask.cgImage!.convertToGrayscale())
            context.draw(image, in: context.bounds)
        })
    }
    
    private func folderRect(_ scale: IconSet.Scale) -> CGRect {
        CGRect(origin: [100, 100] * (scale.size / 1024), size: [824, 824] * (scale.size / 1024))
    }
}

struct FolderCenterEngravedIconTemplete: IconTemplete {
    let title: String = "Folder (Engraved)"
    let identifier: String = "folder_engraved"
    let embossColor = NSColor(patternImage: NSImage(named: "watermark_mask_bs.png")!)
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage {
        let background = backgroundIconSet.image(for: scale)
        
        return NSImage(size: background.size, cgcanvas: { context in
            let sizeImage = IconTempleteHelper.fitToRect(rect: imageRect(scale), image: image, size: background.size)
            context.draw(background.cgImage!, in: context.bounds)
            let maskImage = maskImage(image: sizeImage, color: embossColor.cgColor, size: background.size).cgImage!
            context.setShadow(offset: [0, -2] * (scale.size / 512), blur: 2 * (scale.size / 512), color: NSColor.white.withAlphaComponent(0.2).cgColor)
            context.draw(maskImage, in: context.bounds)
        })
    }
        
    private func maskImage(image: NSImage, color: CGColor, size: CGSize) -> NSImage {
        NSImage(size: size, cgcanvas: { context in
            context.setFillColor(.clear)
            context.fill(context.bounds)
            context.clip(to: context.bounds, mask: image.cgImage!)
            context.setFillColor(color)
            context.fill(context.bounds)
        })
    }
    
    private func imageRect(_ scale: IconSet.Scale) -> CGRect {
        switch scale {
        case .x1024: return CGRect(origin: [248, 235], size: [530, 530])
        default: return CGRect(origin: [130, 115] * (scale.size / 512), size: [255, 255] * (scale.size / 512))
        }
    }
}

struct FolderCenterIconTemplete: IconTemplete {
    let title: String = "Folder (Center)"
    let identifier: String = "folder_center"
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage {
        let background = backgroundIconSet.image(for: scale)
        
        return NSImage(size: background.size, cgcanvas: { context in
            let image = IconTempleteHelper.fitToRect(rect: imageRect(scale), image: image, size: background.size).cgImage!
            context.draw(background.cgImage!, in: context.bounds)
            context.draw(image, in: context.bounds)
        })
    }

    private func imageRect(_ scale: IconSet.Scale) -> CGRect {
        switch scale {
        case .x1024: return CGRect(origin: [248, 235], size: [530, 530])
        default: return CGRect(origin: [130, 115] * (scale.size / 512), size: [255, 255] * (scale.size / 512))
        }
    }
}

struct FolderFillIconTemplete: IconTemplete {
    let title: String = "Folder (Fill)"
    let identifier: String = "folder_fill"
    
    func bake(image: NSImage, scale: IconSet.Scale) -> NSImage {
        let background = backgroundIconSet.image(for: scale)
        let mask = maskIconSet.image(for: scale)
        let top = topIconSet.image(for: scale)
        
        return NSImage(size: background.size, cgcanvas: { context in
            let image = IconTempleteHelper.fillToRect(rect: folderRect(scale), image: image, size: background.size).cgImage!
            
            context.draw(background.cgImage!, in: context.bounds)
            context.clip(to: context.bounds, mask: mask.cgImage!.convertToGrayscale())
            context.draw(image, in: context.bounds)
            context.resetClip()
            context.clip(to: context.bounds, mask: image)
            context.setAlpha(0.75)
            context.draw(top.cgImage!, in: context.bounds)
        })
    }
    
    private func folderRect(_ scale: IconSet.Scale) -> CGRect {
        switch scale {
        case .x1024: return CGRect(origin: [24, 113], size: [974, 820])
        default: return CGRect(origin: [20, 55] * (scale.size / 512), size: [471, 397] * (scale.size / 512))
        }
    }
}

enum IconTempleteHelper {
    static func fillToRect(rect: CGRect, image: NSImage, size: CGSize) -> NSImage {
        NSImage(size: size, cgcanvas: { context in
            let imageSize = image.size * image.size.aspectFillRatio(fillInside: rect.size)
            let imageRect = CGRect(center: rect.center, size: imageSize)
            image.draw(in: imageRect, from: NSRect(size: image.size), operation: .sourceOver, fraction: 1)
        })
    }
    
    static func fitToRect(rect: CGRect, image: NSImage, size: CGSize) -> NSImage {
        NSImage(size: size, cgcanvas: { context in
            let imageSize = image.size * image.size.aspectFitRatio(fitInside: rect.size)
            let imageRect = CGRect(center: rect.center, size: imageSize)
            image.draw(in: imageRect, from: NSRect(size: image.size), operation: .sourceOver, fraction: 1)
        })
    }
}

private let backgroundIconSet = IconSet(bundleResouces: { "folder_back_\($0.point)_bs.png" })!
private let maskIconSet = IconSet(bundleResouces: { "folder_mask2_\($0.point)_bs.png" })!
private let topIconSet = IconSet(
    icon16: Bundle.main.image(forResource: "folder_top_512.png")!.resized(to: [16, 16]),
    icon32: Bundle.main.image(forResource: "folder_top_512.png")!.resized(to: [32, 32]),
    icon64: Bundle.main.image(forResource: "folder_top_512.png")!.resized(to: [64, 64]),
    icon128: Bundle.main.image(forResource: "folder_top_512.png")!.resized(to: [128, 128]),
    icon256: Bundle.main.image(forResource: "folder_top_512.png")!.resized(to: [256, 256]),
    icon512: Bundle.main.image(forResource: "folder_top_512.png")!,
    icon1024: Bundle.main.image(forResource: "folder_top_1024.png")!
)
