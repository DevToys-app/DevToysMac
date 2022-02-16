//
//  ToolManager.swift
//  DevToys
//
//  Created by yuki on 2022/02/12.
//

import CoreUtil
import OrderedCollections

final class ToolManager {
    private var toolCategoryMap = [ToolCategory: [Tool]]()
    private var toolIdentifierMap = [String: Tool]()
    private var categoryIdentifierMap = [String: ToolCategory]()
    private var categories = OrderedSet<ToolCategory>()
    
    func registerTool(_ tool: Tool) {
        self.toolCategoryMap.arrayAppend(tool, forKey: tool.category)
        if !categories.contains(tool.category) {
            self.categories.append(tool.category)
            self.categoryIdentifierMap[tool.category.identifier] = tool.category
        }
        
        assert(toolIdentifierMap[tool.identifier] == nil, "Tool with identifier '\(tool.identifier)' has already been registered.")
        self.toolIdentifierMap[tool.identifier] = tool
    }
    
    func allTools() -> [Tool] {
        self.categories.compactMap{ toolCategoryMap[$0] }.reduce(into: [], +=)
    }
    func toolForIdentifier(_ identifier: String) -> Tool? {
        self.toolIdentifierMap[identifier]
    }
    func categoryForIdentifier(_ identifier: String) -> ToolCategory? {
        self.categoryIdentifierMap[identifier]
    }
    func toolsForCategory(_ category: ToolCategory, _ query: Query) -> [Tool] {
        guard let tools = self.toolCategoryMap[category] else { return [] }
        return tools.filter{ $0.showAlways || query.matches(to: $0.title, $0.sidebarTitle) }
    }
    func flattenRootItems(_ query: Query) -> [Any] {
        var items = [Any]()
        for category in categories {
            if category.shouldHideCategory {
                items.append(contentsOf: toolsForCategory(category, query))
            } else if !toolsForCategory(category, query).isEmpty {
                items.append(category)
            }
        }
        return items
    }
}

final class ToolCategory: Hashable {
    let name: String
    let icon: NSImage?
    let identifier: String
    let shouldHideCategory: Bool
    
    static func == (lhs: ToolCategory, rhs: ToolCategory) -> Bool {
        lhs.identifier == rhs.identifier
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    init(name: String, icon: NSImage?, identifier: String, shouldHideCategory: Bool = false) {
        self.name = name
        self.icon = icon
        self.identifier = identifier
        self.shouldHideCategory = shouldHideCategory
    }
}

final class Tool {
    let title: String
    let identifier: String
    let category: ToolCategory
    let icon: NSImage
    let sidebarTitle: String
    let toolDescription: String
    let showAlways: Bool
    let showOnHome: Bool
    let showOnSidebar: Bool
    private(set) lazy var viewController = makeViewController()
    
    private let makeViewController: () -> NSViewController
    
    init(title: String, identifier: String, category: ToolCategory, icon: NSImage, sidebarTitle: String? = nil, toolDescription: String, showAlways: Bool = false, showOnHome: Bool = true, showOnSidebar: Bool = true, viewController: @autoclosure @escaping () -> NSViewController) {
        self.title = title
        self.identifier = identifier
        self.category = category
        self.icon = icon
        self.sidebarTitle = sidebarTitle ?? title
        self.toolDescription = toolDescription
        self.showAlways = showAlways
        self.showOnHome = showOnHome
        self.showOnSidebar = showOnSidebar
        self.makeViewController = viewController
    }
}
