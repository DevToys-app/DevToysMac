//
//  ControlBackgroundLayer.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class ControlBackgroundLayer: CALoadLayer {
    func update() {
        self.backgroundColor = R.Color.controlBackgroundColor.cgColor
    }
    override func onAwake() {
        self.cornerRadius = R.Size.corner
        self.areAnimationsEnabled = false
    }
}

final class ControlErrorBackgroundLayer: CALoadLayer {
    func update(isError: Bool) {
        if isError {
            self.backgroundColor = NSColor.systemRed.withAlphaComponent(0.5).cgColor
        } else {
            self.backgroundColor = R.Color.controlBackgroundColor.cgColor
        }
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
            self.backgroundColor = R.Color.controlHighlightedBackgroundColor.cgColor
        } else {
            self.backgroundColor = R.Color.controlBackgroundColor.cgColor
        }
    }
    override func onAwake() {
        self.cornerRadius = R.Size.corner
        self.areAnimationsEnabled = false
    }
}
