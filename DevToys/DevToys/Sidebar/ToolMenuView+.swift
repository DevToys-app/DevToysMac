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
    private var searchQuery = Query() { didSet { outlineView.reloadData() } }
    
    private let homeMenu = ToolMenu(R.Image.Sidebar.home, "All Tools", "all", hasOwnAction: true)
    private let convertMenu = ToolMenu(R.Image.Sidebar.convert, "Convertors", "convert", [
        .jsonYamlConvertor, .numberBaseConvertor, .dateConvertor
    ])
    private let coderMenu = ToolMenu(R.Image.Sidebar.encoderDecoder, "Encoder / Decoder", "coder", [
        .htmlDecoder, .urlDecoder, .base64Decoder, .jwtDecoder
    ])
    private let formatMenu = ToolMenu(R.Image.Sidebar.formatter, "Formatters", "format", [
        .jsonFormatter, .xmlFormatter
    ])
    private let generatorMenu = ToolMenu(R.Image.Sidebar.generator, "Generators", "generator", [
        .hashGenerator, .uuidGenerator, .leremIpsumGenerator, .checksumGenerator
    ])
    private let textMenu = ToolMenu(R.Image.Sidebar.text, "Text", "text", [
        .caseConverter, .regexTester
    ])
    private let graphicMenu = ToolMenu(R.Image.Sidebar.graphic, "Media", "graphic", [
        .imageCompressor, .pdfGenerator, .imageConverter
    ])
    private let networkMenu = ToolMenu(R.Image.Sidebar.network, "Network", "network", [
        .networkInfomation,
    ])
    
    private lazy var toolMenus = [
        homeMenu, convertMenu, coderMenu, formatMenu, generatorMenu, textMenu, graphicMenu, networkMenu
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
        self.outlineView.outlineTableColumn = self.outlineView.tableColumns[0]
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        self.outlineView.selectionHighlightStyle = .sourceList
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = "sidebar"
        self.outlineView.indentationPerLevel = 4
    }
    
    override func viewDidAppear() {
        self.getStatePublisher(for: .appModelChannel).compactMap{ $0?.$searchQuery }.switchToLatest()
            .sink{[unowned self] in self.searchQuery = Query($0) }.store(in: &objectBag)
    }
}

extension ToolmenuViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let menu = item as? ToolMenu else { return false }
        return !menu.toolTypes.isEmpty
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return self.toolMenus
                .filter{ !$0.toolTypes.filter{ self.searchQuery.matches(to: $0.toolListTitle) }.isEmpty || $0 === homeMenu }[index]
        }
        guard let menu = item as? ToolMenu else { return () }
        return menu.toolTypes.filter{ self.searchQuery.matches(to: $0.toolListTitle) }[index]
    }
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return self.toolMenus
                .filter{ !$0.toolTypes.filter{ self.searchQuery.matches(to: $0.toolListTitle) }.isEmpty || $0 === homeMenu }.count
        }
        guard let menu = item as? ToolMenu else { return 0 }
        return menu.toolTypes.filter{ self.searchQuery.matches(to: $0.toolListTitle) }.count
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
