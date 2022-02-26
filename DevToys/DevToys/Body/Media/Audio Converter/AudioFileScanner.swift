//
//  FileTreeScanner.swift
//  DevToys
//
//  Created by yuki on 2022/02/22.
//

import CoreUtil

enum AudioFileScanner {
    
    private static var supportedExtensions: Set<String> = [
        "mp2", "mp3", "aac", "flac", "wma", "ogg", "ac3", "m4a", "tta", "ape", "wav", "aiff", "aifc", "gsm", "dct", "au",
        "mp4", "mkv", "mov", "avi", "wmv"
    ]
    
    static func scan(_ url: URL) -> [URL] {
        var urls = [URL]()
        
        func isAudioFile(_ url: URL) -> Bool {
            supportedExtensions.contains(url.pathExtension.lowercased())
        }
        
        if isAudioFile(url) { urls.append(url) }
        
        guard let enumerator = FileManager.default
                .enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants])
        else { return urls }
        
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]) else { continue }
            guard let isRegularFile = resourceValues.isRegularFile, isRegularFile else { continue }
        
            if isAudioFile(fileURL) { urls.append(fileURL) }
        }
        
        return urls
    }
}
