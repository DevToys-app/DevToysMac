//
//  AppModel.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

extension StateChannel {
    static var appModelChannel: StateChannel<AppModel> { .init("AppModel") }
}

extension NSViewController {
    var appModel: AppModel! { getState(for: .appModelChannel) }
}

final class AppModel {
    @RestorableState("app.tooltype") var toolType: ToolType = ToolType.jsonFormatter
    @RestorableState("app.searchQuery") var searchQuery = ""
}
