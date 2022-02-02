//
//  Ex+NSMenuItem.swift
//  CoreUtil
//
//  Created by yuki on 2020/08/20.
//  Copyright © 2020 yuki. All rights reserved.
//

import Cocoa
import Combine

private var actionHandlerKey = 0
private var actionPublisherKey = 0

extension NSMenuItem {
    public convenience init(title: String, image: NSImage? = nil, isSelected: Bool = false, isEnabled: Bool = true, action: (() -> Void)? = nil) {
        self.init()
        self.title = title
        self.image = image
        self.isSelected = isSelected
        if let action = action { self.setAction(action) } 
    }
    
    public var isSelected: Bool {
        get { self.state == .on } set { self.state = newValue ? .on : .off }
    }
    
    public func setAction(_ block: @escaping () -> ()) {
        self.actionHandler.action = block
    }
    
    private var actionHandler: ActionHandler {
        if let handler = objc_getAssociatedObject(self, &actionHandlerKey) as? ActionHandler { return handler }
        let handler = ActionHandler()
        self.target = handler
        self.action = #selector(ActionHandler.run)
        objc_setAssociatedObject(self, &actionHandlerKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return handler
    }
    
    final private class ActionHandler {
        var action: (() -> ())?
        @objc func run(_ sender: Any?) { self.action?() }
    }
}

extension NSMenu {
    public func addItem(title: String, image: NSImage? = nil, isSelected: Bool = false, isEnabled: Bool = true, action: (() -> Void)?) {
        let item = NSMenuItem(title: title, image: image, isSelected: isSelected, isEnabled: isEnabled, action: action)
        self.addItem(item)
    }
}
