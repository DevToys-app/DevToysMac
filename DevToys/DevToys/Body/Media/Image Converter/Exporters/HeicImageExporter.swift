//
//  HeicConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/18.
//

import AVFoundation
import CoreUtil

enum HeicExportError: Error {
    case heicNotSupported
    case cgImageMissing
    case couldNotFinalize
}

enum HeicImageExporter {
    static func export(_ image: NSImage, to url: URL) -> Promise<Void, Error> {
        Promise.asyncError{
            let data = NSMutableData()
            guard let cgImage = image.cgImage else { throw HeicExportError.cgImageMissing }
            guard let destination = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil) else { throw HeicExportError.heicNotSupported }
            CGImageDestinationAddImage(destination, cgImage, [:] as CFDictionary)
            guard CGImageDestinationFinalize(destination) else { throw HeicExportError.couldNotFinalize }
            try data.write(to: url)
        }
    }
}
