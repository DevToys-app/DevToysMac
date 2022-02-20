//
//  GifConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil

struct GifConvertOptions {
    let width: CGFloat
    let fps: Int
}

struct GifConvertTask {
    let title: String
    let movieURL: URL
    let result: Promise<Void, Error>
}

enum GifConverter {
    static func convert(_ movieURL: URL, options: GifConvertOptions, to destinationURL: URL) -> GifConvertTask {
        var arguments = [String]()
        
        arguments.append(contentsOf: ["-i", movieURL.path])
        arguments.append("-filter_complex")
        
        var complex = [String]()
        complex.append("[0:v]")
        com
        complex += "fps=\(options.fps)"
    }
}

/*

 
 ffmpeg -i input.mov -filter_complex "[0:v] fps=10,scale=640:-1,split [a][b];[a] palettegen [p];[b][p] paletteuse=dither=sierra2" output-palette-sierra2.gif
 
 スマホサイズに変換
 ffmpeg -i base_file.mp4 -vf scale=320:-1 -r 10 output.gif
 
 フレームレート
 -r 10
 
 リサイズ（固定比）
 ffmpeg -i base_file.mp4 -vf scale=320:-1 output.gif

 リサイズ（サイズ指定）
 ffmpeg -i base_file.mp4 -s 320x640 output.gif
 
 
 */
