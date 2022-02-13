//
//  Tool+Default.swift
//  DevToys
//
//  Created by yuki on 2022/02/13.
//

extension Tool {
    static let home = Tool(
        title: "Home", identifier: "home", category: .home, icon: R.Image.Sidebar.home,
        sidebarTitle: "Home", toolDescription: "All tools", showAlways: true,
        viewController: AllToolCollectionItemViewController()
    )
    static let jsonYamlConverter = Tool(
        title: "JSON <> Yaml", identifier: "json.yaml", category: .converter,
        icon: R.Image.ToolList.jsonConvert, sidebarTitle: "JSON <> Yaml", toolDescription: "Convert JSON to Yaml",
        viewController: JSONYamlConverterViewController()
    )
}
