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

extension ToolCategory {
    static let convertor = ToolCategory(name: "Converters", identifier: "converters")
}

final class Tool {
    let title: String
    let category: ToolCategory?
    let icon: NSImage
    let sidebarTitle: String
    private(set) lazy var viewController = makeViewController()
    
    private let makeViewController: () -> NSViewController
    
    init(title: String, category: ToolCategory?, icon: NSImage, sidebarTitle: String? = nil, viewController: @autoclosure @escaping () -> NSViewController) {
        self.title = title
        self.category = category
        self.icon = icon
        self.sidebarTitle = sidebarTitle ?? title
        self.makeViewController = viewController
    }
}
