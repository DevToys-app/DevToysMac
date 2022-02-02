//
//  SidebarView+.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class SidebarViewController: NSViewController {
    private let searchView = SidebarSearchViewController()
    private let sidebarView = SidebarView()
    private let toolMenuController = ToolmenuViewController()
    
    override func loadView() {
        self.view = sidebarView
        self.sidebarView.toolMenuView.contentView = toolMenuController.view
        self.addChild(toolMenuController)
        
        self.sidebarView.searchView.contentView = searchView.view
        self.addChild(searchView)
    }
}

final private class SidebarView: NSLoadStackView {
    let searchView = NSPlaceholderView()
    let toolMenuView = NSPlaceholderView()
    
    override func onAwake() {
        self.edgeInsets.top = 48
        self.orientation = .vertical
        
        self.addArrangedSubview(searchView)
        self.addArrangedSubview(SeparatorView())
        self.addArrangedSubview(toolMenuView)
    }
}
