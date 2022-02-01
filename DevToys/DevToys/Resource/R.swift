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
        static let controlFontSize: CGFloat = 11
        
        static let controlHeight: CGFloat = 28
    }
    enum Image {
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
        
        
        enum Sidebar {
            static let home = NSImage(named: "sidebar/home")!
            
            static let convert = NSImage(named: "sidebar/convert")!
            static let jsonConvert = NSImage(named: "sidebar/json.convert")!
            static let numberBaseConvert = NSImage(named: "sidebar/number.base.convert")!
            
            static let encoderDecoder = NSImage(named: "sidebar/encoder.decoder")!
            static let htmlCoder = NSImage(named: "sidebar/html.coder")!
            static let urlCoder = NSImage(named: "sidebar/url.coder")!
            static let base64Coder = NSImage(named: "sidebar/base64.coder")!
            static let jwtCoder = NSImage(named: "sidebar/jwt.coder")!
            
            static let formatter = NSImage(named: "sidebar/formatter")!
            static let jsonFormatter = NSImage(named: "sidebar/json.formatter")!
            
            static let generator = NSImage(named: "sidebar/generator")!
            static let uuidGenerator = NSImage(named: "sidebar/uuid.generator")!
            static let hashGenerator = NSImage(named: "sidebar/hash.generator")!
            static let loremIpsumGenerator = NSImage(named: "sidebar/lorem.ipsum.generator")!
            
            static let text = NSImage(named: "sidebar/text")!
            static let textIspector = NSImage(named: "sidebar/text.ispector")!
            static let regexTester = NSImage(named: "sidebar/regex.testor")!
            static let textDiff = NSImage(named: "sidebar/text.diff")!
            static let markdownPreview = NSImage(named: "sidebar/markdown.preview")!
            
            static let graphic = NSImage(named: "sidebar/graphic")!
            static let colorBlindnessSimulator = NSImage(named: "sidebar/color.blindness.simulator")!
            static let imageCompressor = NSImage(named: "sidebar/image.compressor")!
        }
        
        enum ToolList {
            static let home = NSImage(named: "toollist/home")!
            
            static let convert = NSImage(named: "toollist/convert")!
            static let jsonConvert = NSImage(named: "toollist/json.convert")!
            static let numberBaseConvert = NSImage(named: "toollist/number.base.convert")!
            
            static let encoderDecoder = NSImage(named: "toollist/encoder.decoder")!
            static let htmlCoder = NSImage(named: "toollist/html.coder")!
            static let urlCoder = NSImage(named: "toollist/url.coder")!
            static let base64Coder = NSImage(named: "toollist/base64.coder")!
            static let jwtCoder = NSImage(named: "toollist/jwt.coder")!
            
            static let formatter = NSImage(named: "toollist/formatter")!
            static let jsonFormatter = NSImage(named: "toollist/json.formatter")!
            
            static let generator = NSImage(named: "toollist/generator")!
            static let uuidGenerator = NSImage(named: "toollist/uuid.generator")!
            static let hashGenerator = NSImage(named: "toollist/hash.generator")!
            static let loremIpsumGenerator = NSImage(named: "toollist/lorem.ipsum.generator")!
            
            static let text = NSImage(named: "toollist/text")!
            static let textIspector = NSImage(named: "toollist/text.ispector")!
            static let regexTester = NSImage(named: "toollist/regex.testor")!
            static let textDiff = NSImage(named: "toollist/text.diff")!
            static let markdownPreview = NSImage(named: "toollist/markdown.preview")!
            
            static let graphic = NSImage(named: "toollist/graphic")!
            static let colorBlindnessSimulator = NSImage(named: "toollist/color.blindness.simulator")!
            static let imageCompressor = NSImage(named: "toollist/image.compressor")!
        }
    }
}

