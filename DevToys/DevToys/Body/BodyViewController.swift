//
//  BodyViewController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class BodyViewController: NSViewController {
    private let placeholderView = NSPlaceholderView()
    private var contentViewController: NSViewController?
    
    override func loadView() { self.view = placeholderView }
    
    override func chainObjectDidLoad() {
        appModel.$tool
            .sink{[unowned self] tool in
                self.contentViewController?.removeFromParent()
                self.addChild(tool.viewController)
                self.contentViewController = tool.viewController
                self.placeholderView.contentView = tool.viewController.view
            }
            .store(in: &objectBag)
    }
}
