//
//  HeicConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/18.
//

import AVFoundation
import CoreUtil

enum HEICError: Error {
    case heicNotSupported
    case cgImageMissing
    case couldNotFinalize
}

enum HeicConverter {
    static func export(_ image: NSImage, to url: URL) -> Promise<Void, Error> {
        Promise<Data, Error>.asyncError{ resolve, _ in
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil) else {
                throw HEICError.heicNotSupported
            }

            guard let cgImage = image.cgImage else { throw HEICError.cgImageMissing }

            CGImageDestinationAddImage(imageDestination, cgImage, [:] as CFDictionary)
            guard CGImageDestinationFinalize(imageDestination) else {
                throw HEICError.couldNotFinalize
            }
            resolve(data as Data)
        }
        .tryPeek{ try $0.write(to: url) }
        .eraseToVoid()
    }
}
