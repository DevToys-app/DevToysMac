//
//  ToolManager.swift
//  DevToys
//
//  Created by yuki on 2022/02/12.
//

import CoreUtil

final class ToolManager {
    
    private var toolMap = [ToolCategory?: [Tool]]()
    
    func registerTool(_ tool: Tool) {
        self.toolMap[tool.category]
        
        tool.category
    }
}

struct ToolCategory: Hashable {
    let name: String
}

final class Tool {
    let name: String
    let viewController: NSViewController
    let category: ToolCategory?
    
    init(name: String, category: ToolCategory?, viewController: NSViewController) {
        self.name = name
        self.category = category
        self.viewController = viewController
    }
}



