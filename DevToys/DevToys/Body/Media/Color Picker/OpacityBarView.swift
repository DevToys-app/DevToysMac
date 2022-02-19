//
//  OpacityBarView.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

final class OpacityBarView: NSLoadView {
    var color: Color = .default { didSet { self.updateHandle() } }
    
    private let handleLayer = ColorPickerHandleLayer()
    private let colorLayer = CAGradientLayer.animationDisabled()
    
    override func layout() {
        super.layout()
        self.colorLayer.frame = bounds
        self.updateHandle()
    }
    
    private func updateHandle() {
        handleLayer.color = Color(hue: color.hue, saturation: color.saturation, brightness: color.brightness, alpha: 1).cgColor
        handleLayer.frame.center = [bounds.midX, color.alpha * bounds.height]
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.width.equalTo(32)
        }
        self.wantsLayer = true
        self.layer?.addSublayer(handleLayer)
        self.layer?.addSublayer(colorLayer)
        self.layer?.cornerRadius = R.Size.corner
        self.layer?.borderWidth = 1
        self.layer?.borderColor = CGColor.black.copy(alpha: 0.2)!
        self.layer?.backgroundColor = R.Color.transparentBackground.cgColor
    }
}
