//
//  ViewController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import Cocoa
import CoreUtil

final class AppViewController: NSSplitViewController {
    private let sidebarController = SidebarViewController()
    private let bodyController = BodyViewController()
    
    override func chainObjectDidLoad() {
        // The object chain will be broken on `addSplitViewItem`. So call the manual chain.
        self.sidebarController.chainObject = chainObject
        self.bodyController.chainObject = chainObject
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarController)
        sidebarItem.minimumThickness = 200
        sidebarItem.canCollapse = false
        self.addSplitViewItem(sidebarItem)
        
        let bodyItem = NSSplitViewItem(viewController: bodyController)
        bodyItem.minimumThickness = 480
        bodyItem.canCollapse = false
        self.addSplitViewItem(bodyItem)
        
        splitView.setPosition(220, ofDividerAt: 0)
        
        self.splitView.autosaveName = "app.splitv"
    }
}
