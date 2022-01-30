//
//  ControlBackgroundLayer.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class ControlBackgroundLayer: CALoadLayer {
    func update() {
        self.backgroundColor = NSColor.textColor.withAlphaComponent(0.08).cgColor
    }
    override func onAwake() {
        self.cornerRadius = R.Size.corner
        self.areAnimationsEnabled = false
    }
}

final class ControlButtonBackgroundLayer: CALoadLayer {
    func update(isHighlighted: Bool) {
        self.areAnimationsEnabled = true
        defer { self.areAnimationsEnabled = false }
        
        if isHighlighted {
            self.backgroundColor = NSColor.textColor.withAlphaComponent(0.2).cgColor
        } else {
            self.backgroundColor = NSColor.textColor.withAlphaComponent(0.08).cgColor
        }
    }
    override func onAwake() {
        self.cornerRadius = R.Size.corner
        self.areAnimationsEnabled = false
    }
}
