//
//  GifConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil
import CoreGraphics

struct GifConvertOptions {
    let thumbsize: CGSize
    let width: CGFloat
    let fps: Int
    let removeSourceFile: Bool
}

struct GifConvertTask {
    let thumbnail: NSImage?
    let title: String
    let movieURL: URL
    let destinationURL: URL
    let fftask: Promise<FFTask, Never>
}

enum GifConverter {
    static func convert(_ movieURL: URL, options: GifConvertOptions, to destinationURL: URL) -> Promise<GifConvertTask, Never> {
        var arguments = [String]()
        
        arguments.append("-filter_complex")
        arguments.append("[0:v] fps=\(options.fps),scale=\(options.width):-1,split [a][b];[a] palettegen [p];[b][p] paletteuse")
                
        let fftask = FFExecutor.execute(arguments, inputURL: movieURL, destinationURL: destinationURL)
        let thumbnail = FFThumnailGenerator.thumbnail(of: movieURL, size: options.thumbsize)
        
        fftask.eraseToError().flatMap{ $0.complete }
            .peek{
                if options.removeSourceFile {
                    NSWorkspace.shared.recycle([movieURL], completionHandler: nil)
                    NSSound.dragToTrash?.play()
                }
            }
            .catch({_ in })
        
        return thumbnail.map{
            GifConvertTask(thumbnail: $0, title: movieURL.lastPathComponent, movieURL: movieURL, destinationURL: destinationURL, fftask: fftask)
        }
    }
}

extension NSSound {
    static let dragToTrash = NSSound(contentsOfFile: "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif", byReference: true)
}
