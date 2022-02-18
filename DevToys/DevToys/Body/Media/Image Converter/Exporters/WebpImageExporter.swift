//
//  WebpExporter.swift
//  DevToys
//
//  Created by yuki on 2022/02/18.
//

import CoreUtil

enum WebpExportError: Error {
    case noImageData
}

enum WebpImageExporter {
    private static let cwebpURL = Bundle.current.url(forResource: "cwebp", withExtension: nil)!
    private static let inputDataURL = FileManager.temporaryDirectoryURL.appendingPathComponent("WebpInputData") => {
        try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func export(_ image: NSImage, to url: URL) -> Promise<Void, Error> {
        Promise<URL, Error>.asyncError { resolve, reject in
            let url = inputDataURL.appendingPathComponent(UUID().uuidString)
            guard let data = image.tiffRepresentation else { return reject(WebpExportError.noImageData) }
            try data.write(to: url)
            resolve(url)
        }
        .flatPeek{ Terminal.run(cwebpURL, arguments: [$0.path, "-o", url.path]) }
        .tryPeek{ try FileManager.default.removeItem(at: $0) }
        .eraseToVoid()
    }
}
