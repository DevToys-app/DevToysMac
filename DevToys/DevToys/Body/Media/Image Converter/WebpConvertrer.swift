//
//  WebpConvertrer.swift
//  DevToys
//
//  Created by yuki on 2022/02/18.
//

import CoreUtil

enum WebpConvertError: Error {
    case noImageData
}

enum WebpConvertrer {
    private static let cwebpURL = Bundle.current.url(forResource: "cwebp", withExtension: nil)!
    private static let inputDataURL = FileManager.temporaryDirectoryURL.appendingPathComponent("WebpInputData") => {
        try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func convert(_ image: NSImage, to url: URL) -> Promise<Void, Error> {
        Promise<URL, Error>.asyncError(on: .global()) { resolve, reject in
            let tmpURL = inputDataURL.appendingPathComponent(UUID().uuidString)
            guard let data = image.tiffRepresentation else { return reject(WebpConvertError.noImageData) }
            try data.write(to: tmpURL)
            resolve(tmpURL)
        }
        .flatPeek{ Terminal.run(cwebpURL, arguments: [$0.path, "-o", url.path]) }
        .tryPeek{ try FileManager.default.removeItem(at: $0) }
        .eraseToVoid()
    }
}

extension Promise {
    public func flatPeek<T>(_ tranceform: @escaping (Output) -> Promise<T, Failure>) -> Promise<Output, Failure> {
        Promise{ resolve, reject in
            self.sink({ output in tranceform(output).sink({_ in resolve(output) }, reject) }, reject)
        }
    }
}
