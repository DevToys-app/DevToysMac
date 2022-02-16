//
//  ToolCategory+Default.swift
//  DevToys
//
//  Created by yuki on 2022/02/13.
//

extension ToolCategory {
    static let home = ToolCategory(name: "category.home".localized(), icon: nil, identifier: "home", shouldHideCategory: true)
    static let converter = ToolCategory(name: "category.converters".localized(), icon: R.Image.Tool.convert, identifier: "converters")
    static let encoderDecoder = ToolCategory(name: "category.encoders_decoders".localized(), icon: R.Image.Tool.encoderDecoder, identifier: "encoderDecoder")
    static let formatter = ToolCategory(name: "category.formatters".localized(), icon: R.Image.Tool.formatter, identifier: "formatter")
    static let generator = ToolCategory(name: "category.generators".localized(), icon: R.Image.Tool.generator, identifier: "generator")
    static let text = ToolCategory(name: "category.text".localized(), icon: R.Image.Tool.text, identifier: "text")
    static let graphic = ToolCategory(name: "category.graphic".localized(), icon: R.Image.Tool.graphic, identifier: "graphic")
    static let settings = ToolCategory(name: "Settings", icon: nil, identifier: "settings", shouldHideCategory: true)
}
