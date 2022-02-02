//
//  ToolmenuViewController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class ToolmenuViewController: NSViewController {
    
    private let scrollView = NSScrollView()
    private let outlineView = NSOutlineView.list()
    
    private let homeMenu = ToolMenu(R.Image.Sidebar.home, "All Tools", "all", hasOwnAction: true)
    private let convertMenu = ToolMenu(R.Image.Sidebar.convert, "Convertors", "convert", [
        .jsonYamlConvertor, .numberBaseConvertor
    ])
    private let coderMenu = ToolMenu(R.Image.Sidebar.encoderDecoder, "Encoder / Decoder", "coder", [
        .htmlDecoder, .urlDecoder, .base64Decoder, .jwtDecoder
    ])
    private let formatMenu = ToolMenu(R.Image.Sidebar.formatter, "Formatters", "format", [
        .jsonFormatter
    ])
    private let generatorMenu = ToolMenu(R.Image.Sidebar.generator, "Generators", "generator", [
        .hashGenerator, .uuidGenerator, .leremIpsumGenerator
    ])
    private let textMenu = ToolMenu(R.Image.Sidebar.text, "Text", "text", [
        .caseConverter,
    ])
    private let graphicMenu = ToolMenu(R.Image.Sidebar.graphic, "Graphic", "graphic", [
        .imageCompressor
    ])
    
    private lazy var toolMenus = [
        homeMenu, convertMenu, coderMenu, formatMenu, generatorMenu, textMenu, graphicMenu
    ]
    
    final private class ToolMenu {
        let icon: NSImage
        let title: String
        let identifier: String
        let toolTypes: [ToolType]
        let hasOwnAction: Bool
        
        init(_ icon: NSImage, _ title: String, _ identifier: String, _ toolTypes: [ToolType] = [], hasOwnAction: Bool = false) {
            self.icon = icon
            self.title = title
            self.identifier = identifier
            self.toolTypes = toolTypes
            self.hasOwnAction = hasOwnAction
        }
    }
    
    @objc func onClick(_ outlineView: NSOutlineView) {
        self.onSelect(row: outlineView.clickedRow)
    }
    
    private func onSelect(row: Int) {
        guard let item = outlineView.item(atRow: row) else { return }
        
        if let menu = item as? ToolMenu {
            if menu.identifier == "all" {
                appModel.toolType = .allTools
            }
        } else if let toolType = item as? ToolType {
            appModel.toolType = toolType
        }
    }
    
    override func loadView() {
        self.view = scrollView
        self.scrollView.drawsBackground = false
        self.scrollView.documentView = outlineView
        
        self.outlineView.setTarget(self, action: #selector(onClick))
        self.outlineView.indentationPerLevel = 8
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        self.outlineView.selectionHighlightStyle = .sourceList
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = "sidebar"
    }
}

extension ToolmenuViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let menu = item as? ToolMenu else { return false }
        return !menu.toolTypes.isEmpty
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { return self.toolMenus[index] }
        guard let menu = item as? ToolMenu else { return () }
        return menu.toolTypes[index]
    }
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil { return self.toolMenus.count }
        guard let menu = item as? ToolMenu else { return 0 }
        return menu.toolTypes.count
    }
    
    public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return ToolmenuCell.height
    }
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cell = ToolmenuCell()
        
        if let menu = item as? ToolMenu {
            cell.icon = menu.icon
            cell.title = menu.title
        } else if let tool = item as? ToolType {
            cell.icon = tool.sidebarIcon
            cell.title = tool.sidebarTitle
        }
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        if let menu = item as? ToolMenu {
            return menu.identifier
        } else if let tool = item as? ToolType {
            return tool.rawValue
        }
        return nil
    }
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard let identifier = object as? String else { return nil }
        if let toolMenu = self.toolMenus.first(where: { $0.identifier == identifier }) { return toolMenu }
        if let toolType = ToolType(rawValue: identifier) { return toolType }
        return nil
    }
}

extension ToolmenuViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        self.onSelect(row: outlineView.selectedRow)
    }
}
