//
//  FFMpegExecutor.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil

enum FFMpegExecutor {
    static let ffmpegURL = Bundle.current.url(forResource: "ffmpeg", withExtension: nil)!
    
    static func execute(_ arguments: [String]) -> Promise<String, Never> {
        Terminal.run(ffmpegURL, arguments: arguments)
    }
}
