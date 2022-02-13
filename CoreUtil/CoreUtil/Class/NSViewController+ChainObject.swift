//
//  NSViewController.swift
//  CoreUtil
//
//  Created by yuki on 2021/07/19.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa

private var chainObjectKey = 0
private var chainObjectFlagKey = 0

extension NSViewController {
    public var isChainObjectLoaded: Bool {
        get { objc_getAssociatedObject(self, &chainObjectFlagKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &chainObjectFlagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public var chainObject: Any? {
        get { objc_getAssociatedObject(self, &chainObjectKey) }
        set {
            guard let chainObject = newValue else { return }
            if self.isChainObjectLoaded { return }; self.isChainObjectLoaded = true
            objc_setAssociatedObject(self, &chainObjectKey, chainObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            Self.activateObjectChain
            for child in children { child.chainObject = chainObject }
            self.chainObjectDidLoad()
        }
    }
    
    @objc open func chainObjectDidLoad() {}
    
    static let activateObjectChain: () = method_exchangeImplementations(
        class_getInstanceMethod(NSViewController.self, #selector(addChild))!,
        class_getInstanceMethod(NSViewController.self, #selector(chain_addChild))!
    )
    
    @objc private dynamic func chain_addChild(_ childViewController: NSViewController) {
        childViewController.chainObject = chainObject
        self.chain_addChild(childViewController)
    }
}
