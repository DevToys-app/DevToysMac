//
//  Ex+CALayer.swift
//  CoreUtil
//
//  Created by yuki on 2020/06/23.
//  Copyright © 2020 yuki. All rights reserved.
//

import Cocoa

extension CALayer {
    public static func animationDisabled() -> Self {
        let layer = Self.init()
        layer.areAnimationsEnabled = false
        return layer
    }
}

extension CALayer {
    @objc public var areAnimationsEnabled: Bool {
        get { delegate === CALayerAnimationsDisablingDelegate.shared }
        set { delegate = newValue ? nil : CALayerAnimationsDisablingDelegate.shared }
    }
}

private class CALayerAnimationsDisablingDelegate: NSObject, CALayerDelegate {
    public static let shared = CALayerAnimationsDisablingDelegate()
    let null = NSNull()

    func action(for layer: CALayer, forKey event: String) -> CAAction? { null }
}
