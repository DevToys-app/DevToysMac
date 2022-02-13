//
//  ToolManager.swift
//  DevToys
//
//  Created by yuki on 2022/02/12.
//

import CoreUtil
import OrderedCollections

final class ToolManager {
    
    private var toolMap = [ToolCategory?: [Tool]]()
    private var categoryOrder = OrderedSet<ToolCategory?>()
    
    func registerTool(_ tool: Tool) {
        self.toolMap.arrayAppend(tool, forKey: tool.category)
        if !categoryOrder.contains(tool.category) { categoryOrder.append(tool.category) }
    }
    
    func allToolCategories(_ query: Query) -> [ToolCategory?] {
        categoryOrder.filter{ query.matches(to: $0?.name ?? "") }
    }
}

final class ToolCategory: Hashable {
    let name: String
    let identifier: String
    
    static func == (lhs: ToolCategory, rhs: ToolCategory) -> Bool {
        lhs.identifier == rhs.identifier
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    init(name: String, identifier: String) {
        self.name = name
        self.identifier = identifier
    }
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



