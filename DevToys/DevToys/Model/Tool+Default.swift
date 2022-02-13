//
//  Tool+Default.swift
//  DevToys
//
//  Created by yuki on 2022/02/13.
//

import CoreUtil

extension Tool {
    static let home = Tool(
        title: "tool.home.title".localized(), identifier: "home", category: .home, icon: R.Image.Tool.home,
        toolDescription: "tool.home.description".localized(), showAlways: true, showOnHome: false,
        viewController: HomeViewController()
    )
    
    static let jsonYamlConverter = Tool(
        title: "tool.jsonyaml.title".localized(), identifier: "jsonyaml", category: .converter, icon: R.Image.Tool.jsonConvert,
        sidebarTitle: "tool.jsonyaml.minTitle".localized(), toolDescription: "tool.jsonyaml.description".localized(),
        viewController: JSONYamlConverterViewController()
    )
    static let numberBaseConverter = Tool(
        title: "tool.numbase.title".localized(), identifier: "numbase", category: .converter, icon: R.Image.Tool.numberBaseConvert,
        sidebarTitle: "tool.numbase.minTitle".localized(), toolDescription: "tool.numbase.description".localized(),
        viewController: JSONYamlConverterViewController()
    )
    static let dateConverter = Tool(
        title: "tool.date.title".localized(), identifier: "date.converter", category: .converter, icon: R.Image.Tool.dateConvert,
        sidebarTitle: "tool.date.minTitle".localized(), toolDescription: "tool.date.description".localized(),
        viewController: DateConverterViewController()
    )
    
    static let htmlCoder = Tool(
        title: "tool.html.title".localized(), identifier: "html.converter", category: .converter, icon: R.Image.Tool.htmlCoder,
        sidebarTitle: "tool.html.minTitle".localized(), toolDescription: "tool.html.description".localized(),
        viewController: HTMLDecoderViewController()
    )
    static let urlCoder = Tool(
        title: "tool.url.title".localized(), identifier: "url.converter", category: .converter, icon: R.Image.Tool.urlCoder,
        sidebarTitle: "tool.url.minTitle".localized(), toolDescription: "tool.url.description".localized(),
        viewController: URLDecoderViewController()
    )
    static let base64Coder = Tool(
        title: "tool.base64.title".localized(), identifier: "base64.converter", category: .converter, icon: R.Image.Tool.base64Coder,
        sidebarTitle: "tool.base64.minTitle".localized(), toolDescription: "tool.base64.description".localized(),
        viewController: Base64DecoderViewController()
    )
    static let jwtCoder = Tool(
        title: "tool.jwt.title".localized(), identifier: "jwt.converter", category: .converter, icon: R.Image.Tool.jwtCoder,
        sidebarTitle: "tool.jwt.minTitle".localized(), toolDescription: "tool.jwt.description".localized(),
        viewController: Base64DecoderViewController()
    )
}
