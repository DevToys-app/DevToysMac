//
//  ACOverlayWrapper.swift
//  PixelPicker
//
//  Created by yuki on 2020/06/30.
//  Copyright © 2020 yuki. All rights reserved.
//

import Cocoa

class PPOverlayWrapper: NSView {

    override var wantsUpdateLayer: Bool {
        get { return true }
    }

    override func awakeFromNib() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.cgColor
        layer?.borderColor = NSColor.black.cgColor
        layer?.borderWidth = 1
    }
}
