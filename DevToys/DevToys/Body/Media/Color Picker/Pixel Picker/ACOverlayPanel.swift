//
//  ACOverlayPanel.swift
//  PixelPicker
//
//  Created by yuki on 2020/06/30.
//  Copyright © 2020 yuki. All rights reserved.
//

import Cocoa

class ACOverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func awakeFromNib() {
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        self.level = .popUpMenu
        self.styleMask = .nonactivatingPanel
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.acceptsMouseMovedEvents = true
    }

    func activate(withSize size: CGFloat, infoPanel: ACOverlayPanel) {
        makeKeyAndOrderFront(self)
        setFrame(NSRect(x: frame.origin.x, y: frame.origin.y, width: size + 1, height: size + 1), display: false)
        addChildWindow(infoPanel, ordered: .above)
        let origin = NSPoint(x: frame.midX - infoPanel.frame.width / 2, y: frame.midY - 40)
        infoPanel.setFrameOrigin(origin)
    }
}
