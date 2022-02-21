//
//  AudioConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/21.
//

import CoreUtil

struct AudioConvertOptions {
    let thumbsize: CGSize
    let removeSourceFile: Bool
}

struct AudioConvertTask {
    let title: String
    let sourceURL: URL
    let destinationURL: URL
    let fftask: Promise<FFTask, Never>
}

struct AudioConvertGroup {
    var title: String
    var formats: [AudioConvertFormat]
}

struct AudioConvertFormat: Codable {
    var title: String
    var ext: String
    var options: [String]
}


enum AudioConverter {
    static func convert(from sourceURL: URL, format: AudioConvertFormat, options: AudioConvertOptions, destinationURL: URL) -> AudioConvertTask {
        let fftask = FFExecutor.execute(format.options, inputURL: sourceURL, destinationURL: destinationURL)
        
        fftask.eraseToError().flatMap{ $0.complete }
            .peek{
                if options.removeSourceFile {
                    NSWorkspace.shared.recycle([sourceURL], completionHandler: nil)
                    NSSound.dragToTrash?.play()
                }
            }
            .catch({_ in })
        
        return AudioConvertTask(title: sourceURL.lastPathComponent, sourceURL: sourceURL, destinationURL: destinationURL, fftask: fftask)
    }
}
