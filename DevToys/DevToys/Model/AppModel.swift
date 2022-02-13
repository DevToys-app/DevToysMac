//
//  AppModel.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

extension NSViewController {
    var appModel: AppModel! { chainObject as? AppModel }
}

final class AppModel {
    @Observable var tool: Tool = .home {
        didSet { toolIdentifier = tool.identifier }
    }
    @RestorableState("app.toolIdentifier") var toolIdentifier = ""
    @RestorableState("app.searchQuery") var searchQuery = ""
    
    let toolManager = ToolManager()
    
    init() {
        self.tool = toolManager.toolForIdentifier(toolIdentifier) ?? .home
    }
}
