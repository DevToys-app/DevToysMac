//
//  Button.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

final class Button: NSLoadButton {
    override var intrinsicContentSize: NSSize {
        super.intrinsicContentSize + [12, 0]
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isHighlighted {
            R.Color.controlAccentColor.shadow(withLevel: 0.1)?.setFill()
        } else {
            R.Color.controlAccentColor.setFill()
        }
        
        NSBezierPath(roundedRect: bounds, xRadius: R.Size.corner, yRadius: R.Size.corner).fill()
        (self.title as NSString).draw(center: bounds, attributes: [NSAttributedString.Key.foregroundColor : NSColor.white])
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
        self.isBordered = false
        self.bezelStyle = .rounded
        
        self.actionPublisher
            .sink{ print("action") }.store(in: &objectBag)
    }
}

extension R.Color {
    static var controlAccentColor: NSColor { NSColor.controlAccentColor }
}
