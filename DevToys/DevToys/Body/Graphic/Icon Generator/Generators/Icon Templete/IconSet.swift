//
//  IconSet.swift
//  DevToys
//
//  Created by yuki on 2022/02/27.
//

import CoreUtil



struct IconSet {
    enum Scale {
        case x16, x32, x64, x128, x256, x512, x1024
        
        var size: CGFloat {
            switch self {
            case .x16: return 16
            case .x32: return 32
            case .x64: return 64
            case .x128: return 128
            case .x256: return 256
            case .x512: return 512
            case .x1024: return 1024
            }
        }
        var point: Int { Int(size) }
    }
    
    let icon16: NSImage
    let icon32: NSImage
    let icon64: NSImage
    let icon128: NSImage
    let icon256: NSImage
    let icon512: NSImage
    let icon1024: NSImage
    
    func image(for scale: Scale) -> NSImage {
        switch scale {
        case .x16: return icon16
        case .x32: return icon32
        case .x64: return icon64
        case .x128: return icon128
        case .x256: return icon256
        case .x512: return icon512
        case .x1024: return icon1024
        }
    }
    
    init(icon16: NSImage, icon32: NSImage, icon64: NSImage, icon128: NSImage, icon256: NSImage, icon512: NSImage, icon1024: NSImage) {
        self.icon16 = icon16
        self.icon32 = icon32
        self.icon64 = icon64
        self.icon128 = icon128
        self.icon256 = icon256
        self.icon512 = icon512
        self.icon1024 = icon1024
    }
    
    init?(make: (Scale) -> NSImage?) {
        guard let icon16 = make(.x16), let icon32 = make(.x32), let icon64 = make(.x64), let icon128 = make(.x128), let icon256 = make(.x256), let icon512 = make(.x512), let icon1024 = make(.x1024) else { return nil }
        self.init(icon16: icon16, icon32: icon32, icon64: icon64, icon128: icon128, icon256: icon256, icon512: icon512, icon1024: icon1024)
    }
    
    init?(bundleResouces: (Scale) -> String) {
        self.init(make: { Bundle.main.image(forResource: bundleResouces($0)) })
    }
}

extension IconSet {
    func write(to url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        try self.icon16.png?.write(to: url.appendingPathComponent("icon_16x16.png"))
        try self.icon32.png?.write(to: url.appendingPathComponent("icon_16x16@2x.png"))
        try self.icon32.png?.write(to: url.appendingPathComponent("icon_32x32.png"))
        try self.icon64.png?.write(to: url.appendingPathComponent("icon_32x32@2x.png"))
        try self.icon64.png?.write(to: url.appendingPathComponent("icon_64x64.png"))
        try self.icon128.png?.write(to: url.appendingPathComponent("icon_64x64@2x.png"))
        try self.icon128.png?.write(to: url.appendingPathComponent("icon_128x128.png"))
        try self.icon256.png?.write(to: url.appendingPathComponent("icon_128x128@2x.png"))
        try self.icon256.png?.write(to: url.appendingPathComponent("icon_256x256.png"))
        try self.icon512.png?.write(to: url.appendingPathComponent("icon_256x256@2x.png"))
        try self.icon512.png?.write(to: url.appendingPathComponent("icon_512x512.png"))
        try self.icon1024.png?.write(to: url.appendingPathComponent("icon_512x512@2x.png"))
    }
}
