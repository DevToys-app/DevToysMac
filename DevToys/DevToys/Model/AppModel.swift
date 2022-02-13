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
    @RestorableState("app.tooltype") var toolType: ToolType = ToolType.jsonFormatter
    @RestorableState("app.searchQuery") var searchQuery = ""
    
    let toolManager = ToolManager()
}
