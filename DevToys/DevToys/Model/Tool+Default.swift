//
//  Tool+Default.swift
//  DevToys
//
//  Created by yuki on 2022/02/13.
//

import CoreUtil

extension Tool {
    static let home = Tool(
        title: "category.home".localized(), identifier: "home", category: .home, icon: R.Image.Sidebar.home,
        toolDescription: "All tools", showAlways: true, showOnHome: false,
        viewController: HomeViewController()
    )
    static let jsonYamlConverter = Tool(
        title: "JSON <> Yaml Converter", identifier: "json.yaml", category: .converter, icon: R.Image.ToolList.jsonConvert,
        sidebarTitle: "JSON <> Yaml", toolDescription: "Convert Json data to Yaml and vice versa",
        viewController: JSONYamlConverterViewController()
    )
    static let numberBaseConverter = Tool(
        title: "Number Base Converter", identifier: "num.base", category: .converter, icon: R.Image.ToolList.jsonConvert,
        sidebarTitle: "Number Base", toolDescription: "Convert JSON to Yaml",
        viewController: JSONYamlConverterViewController()
    )
}
