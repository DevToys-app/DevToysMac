//
//  ImageOptimizer.swift
//  DevToys
//
//  Created by yuki on 2022/02/02.
//

import CoreUtil

struct ImageOptimizeTask {
    let title: String
    let url: URL
    let result: Promise<String, Error>
}

enum ImageOptimizeError: Error {
    case noAccessToDirectory(URL)
    case unkownType(fileExtension: String)
}

enum OptimizeLevel: String, TextItem {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High (Slow)"
    
    var title: String { rawValue.localized() }
}

enum ImageOptimizer {
    static func optimize(_ url: URL, optimizeLevel: OptimizeLevel) throws -> ImageOptimizeTask {
        let ext = url.pathExtension.lowercased()
        if ext == "png" { return try PNGOptimizer.optimize(url, optimizeLevel: optimizeLevel) }
        if ext == "jpg" || ext == "jpeg" { return try JPEGOptimizer.optimize(url, optimizeLevel: optimizeLevel) }
        
        throw ImageOptimizeError.unkownType(fileExtension: ext)
    }
}


enum PNGOptimizer {
    private static let optpingURL = Bundle.current.url(forResource: "optipng", withExtension: nil)!
    
    static func optimize(_ url: URL, optimizeLevel: OptimizeLevel) throws -> ImageOptimizeTask {
        var arguments = [String]()
        switch optimizeLevel {
        case .low: arguments.append("-o1")
        case .medium: arguments.append("-o2")
        case .high: arguments.append("-o3")
        case .veryHigh: arguments.append("-o7")
        }
        arguments.append(url.path)
        
        let fileCompression = FileCompression(url: url)
        let promise = Terminal.run(optpingURL, arguments: arguments)
            .map{ _ in
                fileCompression.currentCompressionRatioString()
            }
        
        return ImageOptimizeTask(title: url.lastPathComponent, url: url, result: promise)
    }
}

enum JPEGOptimizer {
    private static let jpegoptimURL = Bundle.current.url(forResource: "jpegoptim", withExtension: nil)!
            
    static func optimize(_ url: URL, optimizeLevel: OptimizeLevel) throws -> ImageOptimizeTask {
        let directoryURL = url.deletingLastPathComponent()
        guard FileAccessChecker.becomeAccessable(to: directoryURL) else { throw ImageOptimizeError.noAccessToDirectory(directoryURL) }
            
        var arguments = [String]()
        switch optimizeLevel {
        case .low: arguments.append(contentsOf: ["--strip-all"])
        case .medium: arguments.append(contentsOf: ["--strip-all", "-m95"])
        case .high: arguments.append(contentsOf: ["--strip-all", "-m90"])
        case .veryHigh: arguments.append(contentsOf: ["--strip-all", "-m80"])
        }
        arguments.append(url.path)
        
        let fileCompression = FileCompression(url: url)
        let promise = Terminal.run(jpegoptimURL, arguments: arguments)
            .map{ _ in
                fileCompression.currentCompressionRatioString()
            }
        
        return ImageOptimizeTask(title: url.lastPathComponent, url: url, result: promise)
    }
}

extension String: Error {}

final class FileCompression {
    let initialSize: Double?
    let url: URL
    
    init(url: URL) {
        self.url = url
        self.initialSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Double
    }
    
    private static let numberFormatter = NumberFormatter() => { $0.maximumFractionDigits = 2 }
    
    func currentCompressionRatioString() -> String {
        let currentSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Double
        
        guard let initialSize = initialSize, let currentSize = currentSize, initialSize != 0 else { return "-%" }
        let percent = currentSize / initialSize * 100
        guard let formattedString = FileCompression.numberFormatter.string(from: NSNumber(value: percent)) else { return "-%" }
        return formattedString + "%"
    }
}

enum FileAccessChecker {
    static func becomeAccessable(to directoryURL: URL) -> Bool {
        if hasAccess(to: directoryURL) { return true }
        let panel = NSOpenPanel()
        panel.message = "Select Open to allow access to '\(directoryURL.lastPathComponent)'"
        panel.directoryURL = directoryURL
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.allowsOtherFileTypes = false
        guard panel.runModal() == .OK else { return false }
        guard panel.url == directoryURL else { return false }
        return true
    }
    static func hasAccess(to directoryURL: URL) -> Bool {
        do {
            let url = directoryURL.deletingLastPathComponent().appendingPathComponent(".devtoys_mac_write_test")
            try Data().write(to: url)
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}
