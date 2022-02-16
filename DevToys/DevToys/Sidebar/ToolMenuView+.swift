//
//  ToolmenuViewController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class ToolMenuViewController: NSViewController {
    
    private let scrollView = NSScrollView()
    private let outlineView = NSOutlineView.list()
    private var searchQuery = Query() { didSet { outlineView.reloadData() } }
    
    @RestorableState("toolmenu.initial") var isInitial = true
        
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
        self.outlineView.floatsGroupRows = false
    }
        
    override func chainObjectDidLoad() {
        self.appModel.$searchQuery
            .sink{[unowned self] in self.searchQuery = Query($0) }.store(in: &objectBag)
        
        // Datasource uses chainObject, call it in `chainObjectDidLoad`
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = "sidebar"
        if self.isInitial {
            self.isInitial = false
            self.outlineView.expandItem(nil, expandChildren: true)
        }
    }
}

extension ToolMenuViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        item is ToolCategory
    }
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is ToolCategory
    }
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        item is Tool
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
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is ToolCategory {
            return ToolCategoryCell.height
        } else {
            return ToolMenuCell.height
        }
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let category = item as? ToolCategory {
            let cell = ToolCategoryCell()
            cell.title = category.name
            return cell
        } else if let tool = item as? Tool {
            let cell = ToolMenuCell()
            cell.title = tool.sidebarTitle
            cell.icon = tool.icon
            return cell
        }
        
        return nil
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
        if let category = appModel.toolManager.categoryForIdentifier(identifier) { return category }
        if let tool = appModel.toolManager.toolForIdentifier(identifier) { return tool }
        return nil
    }
}

extension ToolMenuViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        self.onSelect(row: outlineView.selectedRow)
    }
}
