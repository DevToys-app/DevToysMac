//
//  ToolCategory+Default.swift
//  DevToys
//
//  Created by yuki on 2022/02/13.
//

extension ToolCategory {
    static let home = ToolCategory(name: "Home", icon: nil, identifier: "home", shouldHideCategory: true)
    static let converter = ToolCategory(name: "Converters", icon: R.Image.Sidebar.convert, identifier: "converters")
    static let encoderDecoder = ToolCategory(name: "Encoders / Decoders", icon: R.Image.Sidebar.encoderDecoder, identifier: "encoderDecoder")
    static let formatter = ToolCategory(name: "Formatters", icon: R.Image.Sidebar.formatter, identifier: "formatter")
    static let generator = ToolCategory(name: "Generators", icon: R.Image.Sidebar.generator, identifier: "generator")
    static let text = ToolCategory(name: "Text", icon: R.Image.Sidebar.text, identifier: "text")
    static let graphic = ToolCategory(name: "Graphic", icon: R.Image.Sidebar.graphic, identifier: "graphic")
}
