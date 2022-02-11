//
//  ImageOptimizer.swift
//  DevToys
//
//  Created by yuki on 2022/02/02.
//

import CoreUtil

struct ImageOptimizeTask {
    let title: String
    let result: Promise<String, Error>
}

enum OptimizeLevel: String, TextItem {
    case low = "Low"
    case mediam = "Mediam"
    case high = "High"
    case veryHigh = "Very High (Slow)"
    
    var title: String { rawValue }
}

enum ImageOptimizer {
    static func optimize(_ url: URL, optimizeLevel: OptimizeLevel) -> ImageOptimizeTask? {
        let ext = url.pathExtension.lowercased()
        if ext == "png" { return PngOptimizer.optimize(url, optimizeLevel: optimizeLevel) }
        if ext == "jpg" || ext == "jpeg" { return JpegOptimizer.optimize(url, optimizeLevel: optimizeLevel) }
        
        return nil
    }
}


enum PngOptimizer {
    private static let optpingURL = Bundle.current.url(forResource: "optipng", withExtension: nil)
    private static let numberFormatter = NumberFormatter() => { $0.maximumFractionDigits = 2 }
    
    static func optimize(_ url: URL, optimizeLevel: OptimizeLevel) -> ImageOptimizeTask? {
        guard let optpingURL = self.optpingURL else { assertionFailure(); return nil }
        
        var arguments = [String]()
        switch optimizeLevel {
        case .low: arguments.append("-o1")
        case .mediam: arguments.append("-o2")
        case .high: arguments.append("-o3")
        case .veryHigh: arguments.append("-o7")
        }
        arguments.append(url.path)
        
        let oldFileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Double
        let promise = Terminal.run(optpingURL, arguments: arguments)
            .peekError{ print($0) }
            .map{ _ -> String in
                let newFileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Double
                
                if let oldFileSize = oldFileSize, let newFileSize = newFileSize {
                    let percent = newFileSize / oldFileSize * 100
                    let result = (numberFormatter.string(from: NSNumber(value: percent)) ?? "[Unkown]") + "%"
                    return result
                } else {
                    return "[Unkown file size]"
                }
            }
        
        return .init(title: url.lastPathComponent, result: promise)
    }
}

enum JpegOptimizer {
    private static let jpegoptimURL = Bundle.current.url(forResource: "jpegoptim", withExtension: nil)
    private static let dylibURL = Bundle.current.url(forResource: "jpegoptim", withExtension: nil)
    
    static func load() {
        
    }
    
    private static let numberFormatter = NumberFormatter() => {
        $0.maximumFractionDigits = 2
    }
    
    static func optimize(_ url: URL, optimizeLevel: OptimizeLevel) -> ImageOptimizeTask? {
        fatalError()
//        guard let optpingURL = self.optpingURL else { assertionFailure(); return nil }
//        let task = Process()
//        var arguments = [String]()
//        switch optimizeLevel {
//        case .low: arguments.append(contentsOf: ["--strip-all"])
//        case .mediam: arguments.append(contentsOf: ["--strip-all", "-m95"])
//        case .high: arguments.append(contentsOf: ["--strip-all", "-m90"])
//        case .veryHigh: arguments.append(contentsOf: ["--strip-all", "-m80"])
//        }
//        arguments.append(url.path)
//
//        let outputPipe = Pipe()
//        let errorPipe = Pipe()
//
//        task.executableURL = optpingURL
//        task.arguments = arguments
//        task.standardOutput = outputPipe
//        task.standardError = errorPipe
//
//        let promise = Promise<String, Error>.asyncError(on: .global()) { resolve, reject in
//
//            let oldFileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Double
//            task.launch()
//            task.waitUntilExit()
//            let newFileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Double
//
//            if task.terminationStatus != 0 {
//                let error = errorPipe.readStringToEndOfFile ?? "Error"
//                reject(error)
//            } else {
//                if let oldFileSize = oldFileSize, let newFileSize = newFileSize {
//                    let percent = newFileSize / oldFileSize * 100
//                    let result = (numberFormatter.string(from: NSNumber(value: percent)) ?? "[Unkown]") + "%"
//                    resolve(result)
//                } else {
//                    resolve("[Unkown]")
//                }
//            }
//        }
//
//        return .init(title: url.lastPathComponent, result: promise)
    }
}

extension String: Error {}
