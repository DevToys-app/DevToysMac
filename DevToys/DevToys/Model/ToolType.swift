//
//  ToolType.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import Cocoa

enum ToolType: String, CaseIterable {
    case allTools
        
    case jsonYamlConvertor
    case numberBaseConvertor
    case dateConvertor
    
    case htmlDecoder
    case urlDecoder
    case base64Decoder
    case jwtDecoder
    
    case jsonFormatter
    case xmlFormatter
    
    case hashGenerator
    case uuidGenerator
    case loremIpsumGenerator
    case checksumGenerator
    
    case caseConverter
    case regexTester
    case hyphenationRemover

    case imageCompressor
    case pdfGenerator
    case imageConverter
    
    case networkInformation
    case apiTest
}

extension ToolType {
    var sidebarIcon: NSImage {
        switch self {
        case .allTools: return R.Image.Sidebar.home
        case .jsonYamlConvertor: return R.Image.Sidebar.jsonConvert
        case .numberBaseConvertor: return R.Image.Sidebar.numberBaseConvert
        case .htmlDecoder: return R.Image.Sidebar.htmlCoder
        case .urlDecoder: return R.Image.Sidebar.urlCoder
        case .base64Decoder: return R.Image.Sidebar.base64Coder
        case .jwtDecoder: return R.Image.Sidebar.jwtCoder
        case .jsonFormatter: return R.Image.Sidebar.jsonFormatter
        case .xmlFormatter: return R.Image.Sidebar.jsonFormatter
        case .hashGenerator: return R.Image.Sidebar.hashGenerator
        case .uuidGenerator: return R.Image.Sidebar.uuidGenerator
        case .loremIpsumGenerator: return R.Image.Sidebar.loremIpsumGenerator
        case .checksumGenerator: return R.Image.Sidebar.hashGenerator
        case .caseConverter: return R.Image.Sidebar.textInspector
        case .regexTester: return R.Image.Sidebar.regexTester
        case .hyphenationRemover: return R.Image.Sidebar.textIspector
        case .imageCompressor: return R.Image.Sidebar.imageCompressor
        case .imageConverter: return R.Image.Sidebar.imageCompressor
        case .pdfGenerator: return R.Image.Sidebar.graphic
        case .networkInformation: return R.Image.Sidebar.network
        case .apiTest: return R.Image.Sidebar.api
        case .dateConvertor: return R.Image.speed
        }
    }
    var toolListIcon: NSImage {
        switch self {
        case .allTools: return R.Image.ToolList.home
        case .jsonYamlConvertor: return R.Image.ToolList.jsonConvert
        case .numberBaseConvertor: return R.Image.ToolList.numberBaseConvert
        case .htmlDecoder: return R.Image.ToolList.htmlCoder
        case .urlDecoder: return R.Image.ToolList.urlCoder
        case .base64Decoder: return R.Image.ToolList.base64Coder
        case .jwtDecoder: return R.Image.ToolList.jwtCoder
        case .jsonFormatter: return R.Image.ToolList.jsonFormatter
        case .xmlFormatter: return R.Image.ToolList.jsonFormatter
        case .hashGenerator: return R.Image.ToolList.hashGenerator
        case .uuidGenerator: return R.Image.ToolList.uuidGenerator
        case .loremIpsumGenerator: return R.Image.ToolList.loremIpsumGenerator
        case .checksumGenerator: return R.Image.ToolList.hashGenerator
        case .caseConverter: return R.Image.ToolList.textInspector
        case .regexTester: return R.Image.ToolList.regexTester
        case .hyphenationRemover: return R.Image.ToolList.textIspector
        case .imageCompressor: return R.Image.ToolList.imageCompressor
        case .imageConverter: return R.Image.ToolList.imageCompressor
        case .pdfGenerator: return R.Image.ToolList.graphic
        case .networkInformation: return R.Image.ToolList.network
        case .apiTest: return R.Image.ToolList.api
        case .dateConvertor: return R.Image.speed
        }
    }
    
    var sidebarTitle: String {
        switch self {
        case .allTools: return "Home"
        case .jsonYamlConvertor: return "JSON <> Yaml"
        case .numberBaseConvertor: return "Number Base"
        case .htmlDecoder: return "HTML"
        case .urlDecoder: return "URL"
        case .base64Decoder: return "Base 64"
        case .jwtDecoder: return "JWT Decoder"
        case .jsonFormatter: return "JSON"
        case .xmlFormatter: return "XML"
        case .hashGenerator: return "Hash"
        case .uuidGenerator: return "UUID"
        case .loremIpsumGenerator: return "Lorem Ipsum"
        case .checksumGenerator: return "Checksum"
        case .caseConverter: return "Inspector & Case Converter"
        case .regexTester: return "Regex"
        case .hyphenationRemover: return "Hyphen Remover"
        case .imageCompressor: return "PNG / JPEG Compressor"
        case .imageConverter: return "Image Converter"
        case .pdfGenerator: return "PDF Generator"
        case .networkInformation: return "Information"
        case .apiTest: return "API"
        case .dateConvertor: return "Date"
        }
    }
    
    var toolListTitle: String {
        switch self {
        case .allTools: return "Home"
        case .jsonYamlConvertor: return "JSON <> Yaml"
        case .numberBaseConvertor: return "Number Base Converter"
        case .htmlDecoder: return "HTML Encoder / Decoder"
        case .urlDecoder: return "URL Encoder / Decoder"
        case .base64Decoder: return "Base 64 Encoder / Decoder"
        case .jwtDecoder: return "JWT Decoder"
        case .jsonFormatter: return "JSON Formatter"
        case .xmlFormatter: return "XML Formatter"
        case .hashGenerator: return "Hash Generator"
        case .uuidGenerator: return "UUID Generator"
        case .loremIpsumGenerator: return "Lorem Ipsum Generator"
        case .checksumGenerator: return "Checksum Generator"
        case .caseConverter: return "Text Case Converter and Inspector"
        case .regexTester: return "Regex Tester"
        case .hyphenationRemover: return "Hyphenation Remover"
        case .pdfGenerator: return "PDF Generator"
        case .imageCompressor: return "PNG / JPEG Compressor"
        case .imageConverter: return "Image Converter"
        case .networkInformation: return "Network Information"
        case .apiTest: return "API Tester"
        case .dateConvertor: return "Date Converter"
        }
    }
    
    var toolDescription: String {
        switch self {
        case .allTools: return "All Tools"
        case .jsonYamlConvertor: return "Convert Json data to Yaml and vice versa"
        case .numberBaseConvertor: return "Convert numbers from one base to another"
        case .htmlDecoder: return "Encoder or decode all the applicable charactors to their corresponding HTML"
        case .urlDecoder: return "Encoder or decode all the applicable charactors to their corresponding URL"
        case .base64Decoder: return "Encode and decode Base64 data"
        case .jwtDecoder: return "Decode a JWT header playload and signature"
        case .jsonFormatter: return "Indent or minify Json data"
        case .xmlFormatter: return "Indent or minify XML data"
        case .hashGenerator: return "Calculate MD5, SHA1, SHA256 and SHA 512 hash from text data"
        case .uuidGenerator: return "Generate UUIDs version 1 and 4"
        case .loremIpsumGenerator: return "Generate Lorem Ipsum placeholder text"
        case .checksumGenerator: return "Generate or Test checksum of a file"
        case .caseConverter: return "Analyze text and convert it to differenct case"
        case .regexTester: return "Test reguler expression"
        case .hyphenationRemover: return "Remove hyphenations copied from PDF text"
        case .pdfGenerator: return "Generate PDF from images"
        case .imageCompressor: return "Lossless PNG and JPEG optimizer"
        case .imageConverter: return "Convert image format and size"
        case .networkInformation: return "Observe network information"
        case .apiTest: return "Send request to servers"
        case .dateConvertor: return "Convert date to other style"
        }
    }
}
