//
//  FileConflictAvoider.swift
//  DevToys
//
//  Created by yuki on 2022/02/22.
//

import CoreUtil

enum FileConflictAvoider {
    
    private static let autoFilenameRegex = try! NSRegularExpression(pattern: #"(.*)\s\(\d+\)$"#, options: [])
    
    static func avoidConflict(_ url: URL) -> URL {
        let ext = url.pathExtension
        let basename = url.deletingLastPathComponent()
        let filename = filterAutoSuffix(url.deletingPathExtension().lastPathComponent)
        
        let rfilename = Identifier.make(with: .brackedNumberPostfix(filename)) {
            !FileManager.default.fileExists(atPath: basename.appendingPathComponent($0).appendingPathExtension(ext).path)
        }
        
        let result = basename.appendingPathComponent(rfilename).appendingPathExtension(ext)
        return result
    }
    
    private static func filterAutoSuffix(_ filename: String) -> String {
        let nsString = filename as NSString
        guard let match = autoFilenameRegex.matches(in: filename, options: [], range: NSRange(location: 0, length: nsString.length)).first else { return filename }
        print(match)
        guard match.numberOfRanges >= 2 else { return filename }
        let basename = nsString.substring(with: match.range(at: 1))
        
        return basename
    }
}
