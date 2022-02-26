//
//  ToolmenuViewController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class SidebarViewController: NSViewController {
    
    private let searchViewController = SidebarSearchCellController()
    private let outlineView = SidebarOutlineView.list()
    private let scrollView = NSScrollView()
    
    @RestorableState("toolmenu.initial") private var isInitial = true
        
    @objc func onClick(_ outlineView: NSOutlineView) {
        self.onSelect(row: outlineView.clickedRow)
    }
    
    private func onSelect(row: Int) {
        guard let tool = outlineView.item(atRow: row) as? Tool else { return }
        self.appModel.tool = tool
    } 
    
    override func loadView() {
        self.view = scrollView
        self.scrollView.documentView = outlineView
        self.scrollView.drawsBackground = false
        
        self.outlineView.setTarget(self, action: #selector(onClick))
        self.outlineView.outlineTableColumn = self.outlineView.tableColumns[0]
        self.outlineView.selectionHighlightStyle = .sourceList
        self.outlineView.floatsGroupRows = false
        self.addChild(searchViewController)
    }
        
    override func chainObjectDidLoad() {
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

final private class SidebarOutlineView: NSOutlineView {
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let row = row(at: event.location(in: self))
        if row >= 0, let cell = self.view(atColumn: 0, row: row, makeIfNecessary: false) as? SidebarSearchCell,
           window?.firstResponder !== cell.searchView
        {
            window?.makeFirstResponder(cell.searchView)
        }
    }
}

extension SidebarViewController: NSOutlineViewDataSource {
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
        if item == nil {
            if index == 0 {
                return ()
            } else {
                return appModel.toolManager.flattenRootItems()[index-1]
            }
        }
        guard let category = item as? ToolCategory else { return () }
        return appModel.toolManager.toolsForCategory(category)[index]
    }
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil { return appModel.toolManager.flattenRootItems().count + 1 }
        guard let category = item as? ToolCategory else { return 0 }
        return appModel.toolManager.toolsForCategory(category).count
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is ToolCategory {
            return ToolCategoryCell.height
        } else if item is Tool {
            return ToolMenuCell.height
        } else {
            return SidebarSearchCell.height
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
        } else if item is Void {
            return searchViewController.view
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

extension SidebarViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        self.onSelect(row: outlineView.selectedRow)
    }
}
