//
//  AppWindowController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import Cocoa

final class AppWindowController: NSWindowController {
    let appModel = AppModel()
    
    override var contentViewController: NSViewController? {
        didSet {
            self.appModel.toolManager.registerTool(
                Tool(title: "JSON <> Yaml", category: .convertor, icon: R.Image.ToolList.jsonConvert, sidebarTitle: "JSON <> Yaml", viewController: JSONYamlConverterViewController())
            )
            
            self.contentViewController?.chainObject = appModel
        }
    }
}
