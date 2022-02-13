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
        
    @objc func onClick(_ outlineView: NSOutlineView) {
        self.onSelect(row: outlineView.clickedRow)
    }
    
    private func onSelect(row: Int) {
        guard let tool = outlineView.item(atRow: row) as? Tool else { return }
        self.appModel.tool = tool
    } 
    
    override func loadView() {
        self.view = scrollView
        self.scrollView.drawsBackground = false
        self.scrollView.documentView = outlineView
        
        self.outlineView.setTarget(self, action: #selector(onClick))
        self.outlineView.outlineTableColumn = self.outlineView.tableColumns[0]
        self.outlineView.selectionHighlightStyle = .sourceList
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = "sidebar"
        self.outlineView.indentationPerLevel = 4
    }
        
    override func chainObjectDidLoad() {
        self.appModel.$searchQuery
            .sink{[unowned self] in self.searchQuery = Query($0) }.store(in: &objectBag)
        
        // Datasource uses chainObject, call it in `chainObjectDidLoad`
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
    }
}

extension ToolmenuViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is ToolCategory
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { return appModel.toolManager.flattenRootItems(searchQuery)[index] }
        guard let category = item as? ToolCategory else { return () }
        return appModel.toolManager.toolsForCategory(category, searchQuery)[index]
    }
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil { return appModel.toolManager.flattenRootItems(searchQuery).count }
        guard let category = item as? ToolCategory else { return 0 }
        return appModel.toolManager.toolsForCategory(category, searchQuery).count
    }
    
    public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return ToolmenuCell.height
    }
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cell = ToolmenuCell()
        
        if let category = item as? ToolCategory {
            cell.title = category.name
            cell.icon = category.icon
        } else if let tool = item as? Tool {
            cell.title = tool.title
            cell.icon = tool.icon
        }
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        if let category = item as? ToolCategory {
            return category.identifier
        } else if let tool = item as? Tool {
            return tool.identifier
        }
        return nil
    }
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard let identifier = object as? String else { return nil }
        return appModel.toolManager.toolForIdentifier(identifier) ?? appModel.toolManager.categoryForIdentifier(identifier)
    }
}

extension ToolmenuViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        self.onSelect(row: outlineView.selectedRow)
    }
}
