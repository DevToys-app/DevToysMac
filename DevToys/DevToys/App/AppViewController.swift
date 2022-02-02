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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarController)
        sidebarItem.minimumThickness = 180
        sidebarItem.canCollapse = false
        self.addSplitViewItem(sidebarItem)
        self.linkState(for: .appModelChannel, to: sidebarController)
        
        let bodyItem = NSSplitViewItem(viewController: bodyController)
        bodyItem.minimumThickness = 480
        bodyItem.canCollapse = false
        self.addSplitViewItem(bodyItem)
        self.linkState(for: .appModelChannel, to: bodyController)
    }
}
