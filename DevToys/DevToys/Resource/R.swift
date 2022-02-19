//
//  R.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import Cocoa

enum R {
    enum Size {
        static let corner: CGFloat = 5
        
        static let controlTitleFontSize: CGFloat = 12
        static let controlFontSize: CGFloat = 10.5
        static let codeFontSize: CGFloat = 12
        
        static let controlHeight: CGFloat = 26
    }
    enum Color {
        static var controlBackgroundColor: NSColor { NSColor.textColor.withAlphaComponent(0.08) }
        static var controlHighlightedBackgroundColor: NSColor { NSColor.textColor.withAlphaComponent(0.15) }
        static let transparentBackground = NSColor(patternImage: NSImage(named: "transparent_background")!)
    }
    enum Image {
        static let spuit = NSImage(named: "spuit")!
        static let check = NSImage(named: "check")!
        static let error = NSImage(named: "error")!
        
        static let spacing = NSImage(named: "spacing")!
        static let clear = NSImage(named: "clear")!
        static let open = NSImage(named: "open")!
        static let paste = NSImage(named: "paste")!
        static let copy = NSImage(named: "copy")!
        
        static let convert = NSImage(named: "convert")!
        static let format = NSImage(named: "format")!
        static let hyphen = NSImage(named: "hyphen")!
        static let paramators = NSImage(named: "paramators")!
        static let settings = NSImage(named: "settings")!
        static let number = NSImage(named: "number")!
        static let text = NSImage(named: "text")!
        
        static let stepperUp = NSImage(named: "stepper.up")!
        static let stepperDown = NSImage(named: "stepper.down")!
        
        static let ipaddress = NSImage(named: "ipaddress")!
        static let networkStatus = NSImage(named: "network.status")!
        static let speed = NSImage(named: "speed")!
        static let drop = NSImage(named: "drop")!
        static let export = NSImage(named: "export")!
        
        enum Tool {
            static let home = NSImage(named: "tool/home")!
            static let settings = NSImage(named: "tool/settings")!
            
            static let convert = NSImage(named: "tool/convert")!
            static let jsonConvert = NSImage(named: "tool/json.convert")!
            static let numberBaseConvert = NSImage(named: "tool/number.base.convert")!
            static let dateConvert = NSImage(named: "tool/date.convert")!
            
            static let encoderDecoder = NSImage(named: "tool/encoder.decoder")!
            static let htmlCoder = NSImage(named: "tool/html.coder")!
            static let urlCoder = NSImage(named: "tool/url.coder")!
            static let base64Coder = NSImage(named: "tool/base64.coder")!
            static let jwtCoder = NSImage(named: "tool/jwt.coder")!
            
            static let formatter = NSImage(named: "tool/formatter")!
            static let jsonFormatter = NSImage(named: "tool/json.formatter")!
            static let xmlFormatter = NSImage(named: "tool/xml.formatter")!
            
            static let generator = NSImage(named: "tool/generator")!
            static let uuidGenerator = NSImage(named: "tool/uuid.generator")!
            static let hashGenerator = NSImage(named: "tool/hash.generator")!
            static let loremIpsumGenerator = NSImage(named: "tool/lorem.ipsum.generator")!
            
            static let text = NSImage(named: "tool/text")!
            static let textInspector = NSImage(named: "tool/text.inspector")!
            static let regexTester = NSImage(named: "tool/regex.tester")!
            static let textDiff = NSImage(named: "tool/text.diff")!
            static let markdownPreview = NSImage(named: "tool/markdown.preview")!
            
            static let graphic = NSImage(named: "tool/graphic")!
            static let pdfGenerator = NSImage(named: "tool/pdf")!
            static let colorBlindnessSimulator = NSImage(named: "tool/color.blindness.simulator")!
            static let imageCompressor = NSImage(named: "tool/image.compressor")!
            static let imageConverter = NSImage(named: "tool/image.converter")!
            
            static let network = NSImage(named: "tool/network")!
            static let api = NSImage(named: "tool/api")!
        }
    }
}

extension Bundle {
    static let current = Bundle(for: { class __ {}; return  __.self }())
}
