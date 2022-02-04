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
    
    case htmlDecoder
    case urlDecoder
    case base64Decoder
    case jwtDecoder
    
    case jsonFormatter
    
    case hashGenerator
    case uuidGenerator
    case leremIpsumGenerator
    case checksumGenerator
    
    case caseConverter
    case regexTester
    
    case imageCompressor
    case pdfGenerator
    
    case networkInfomation
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
        case .hashGenerator: return R.Image.Sidebar.hashGenerator
        case .uuidGenerator: return R.Image.Sidebar.uuidGenerator
        case .leremIpsumGenerator: return R.Image.Sidebar.loremIpsumGenerator
        case .checksumGenerator: return R.Image.Sidebar.hashGenerator
        case .caseConverter: return R.Image.Sidebar.textIspector
        case .regexTester: return R.Image.Sidebar.regexTester
        case .imageCompressor: return R.Image.Sidebar.imageCompressor
        case .pdfGenerator: return R.Image.Sidebar.graphic
        case .networkInfomation: return R.Image.Sidebar.network
        case .apiTest: return R.Image.Sidebar.api
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
        case .hashGenerator: return R.Image.ToolList.hashGenerator
        case .uuidGenerator: return R.Image.ToolList.uuidGenerator
        case .leremIpsumGenerator: return R.Image.ToolList.loremIpsumGenerator
        case .checksumGenerator: return R.Image.ToolList.hashGenerator
        case .caseConverter: return R.Image.ToolList.textIspector
        case .regexTester: return R.Image.ToolList.regexTester
        case .imageCompressor: return R.Image.ToolList.imageCompressor
        case .pdfGenerator: return R.Image.ToolList.graphic
        case .networkInfomation: return R.Image.ToolList.network
        case .apiTest: return R.Image.ToolList.api
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
        case .hashGenerator: return "Hash"
        case .uuidGenerator: return "UUID"
        case .leremIpsumGenerator: return "Lorem Ipsum"
        case .checksumGenerator: return "Checksum"
        case .caseConverter: return "Inspector & Case Converter"
        case .regexTester: return "Regex"
        case .imageCompressor: return "PNG / JPEG Compressor"
        case .pdfGenerator: return "PDF Generator"
        case .networkInfomation: return "Infomation"
        case .apiTest: return "API"
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
        case .hashGenerator: return "Hash Generator"
        case .uuidGenerator: return "UUID Generator"
        case .leremIpsumGenerator: return "Lorem Ipsum Generator"
        case .checksumGenerator: return "Checksum Generator"
        case .caseConverter: return "Text Case Converter and Inspector"
        case .regexTester: return "Regex Tester"
        case .pdfGenerator: return "PDF Generator"
        case .imageCompressor: return "PNG / JPEG Compressor"
        case .networkInfomation: return "Network Infomation"
        case .apiTest: return "API Tester"
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
        case .hashGenerator: return "Calculate MD5, SHA1, SHA256 and SHA 512 hash from text data"
        case .uuidGenerator: return "Generate UUIDs version 1 and 4"
        case .leremIpsumGenerator: return "Generate Lorem Ipsum placeholder text"
        case .checksumGenerator: return "Generate or Test checksum of a file"
        case .caseConverter: return "Analyze text and convert it to differenct case"
        case .regexTester: return "Test reguler expression"
        case .pdfGenerator: return "Generate PDF from images"
        case .imageCompressor: return "Lossless PNG and JPEG optimizer"
        case .networkInfomation: return "Observe network infomation"
        case .apiTest: return "Send request to servers"
        }
    }
}
