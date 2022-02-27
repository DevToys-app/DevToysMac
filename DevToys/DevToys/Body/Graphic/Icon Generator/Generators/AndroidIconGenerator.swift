//
//  AndroidIconGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/27.
//

import CoreUtil

enum AndroidIconGenerator {
    struct ExportOptions: OptionSet {
        let rawValue: UInt64
        
        static let iphone = ExportOptions(rawValue: 1 << 0)
        static let ipad = ExportOptions(rawValue: 1 << 1)
        static let carplay = ExportOptions(rawValue: 1 << 2)
        static let mac = ExportOptions(rawValue: 1 << 3)
        static let applewatch = ExportOptions(rawValue: 1 << 4)
    }
    
    static func make(item: ImageItem, options: ExportOptions, to destinationURL: URL) -> IconGenerateTask {
        fatalError()
    }
}
