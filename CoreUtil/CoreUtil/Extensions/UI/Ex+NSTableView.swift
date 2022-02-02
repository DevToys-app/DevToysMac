//
//  Ex+NSTableView.swift
//  CoreUtil
//
//  Created by yuki on 2022/01/29.
//

import Cocoa

extension NSTableView {
    public static let listColumnIdentifier = NSUserInterfaceItemIdentifier("$_column")
        
    public func becomeListStyle() {
        let column = NSTableColumn(identifier: Self.listColumnIdentifier)
        column.resizingMask = .autoresizingMask

        // column
        self.addTableColumn(column)
        self.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        self.allowsColumnResizing = false
        self.allowsColumnSelection = false

        // appearance
        self.headerView = nil
        self.intercellSpacing = .zero
        self.focusRingType = .none

        // behavior
        self.allowsEmptySelection = true
        self.allowsMultipleSelection = false
        self.backgroundColor = .clear
        
        if #available(OSX 11.0, *) { self.style = .plain }
    }
    
    /// 1コラムのみのTableView
    public static func list() -> Self {
        let tableView = Self()
        tableView.becomeListStyle()
        return tableView
    }
}

