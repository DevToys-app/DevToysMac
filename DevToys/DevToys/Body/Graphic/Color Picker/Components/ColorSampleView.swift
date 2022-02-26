//
//  ColorSampleView.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

final class ColorSampleView: NSLoadView {
    var color: CGColor = .white {
        didSet { colorLayer.backgroundColor = color }
    }
    
    private let colorLayer = CALayer.animationDisabled()
    
    override func layout() {
        super.layout()
        self.colorLayer.frame = bounds
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.width.equalTo(64)
            make.height.equalTo(R.Size.controlHeight)
        }
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.black.withAlphaComponent(0.2).cgColor
        self.layer?.backgroundColor = R.Color.transparentBackground.cgColor
        self.layer?.addSublayer(colorLayer)
        self.colorLayer.backgroundColor = .white
    }
}
