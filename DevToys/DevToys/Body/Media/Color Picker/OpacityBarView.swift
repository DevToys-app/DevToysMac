//
//  OpacityBarView.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

final class OpacityBarView: NSLoadView {
    var color: Color = .default { didSet { self.updateHandle(); updateColorLayer() } }
    let opacityPublisher = PassthroughSubject<CGFloat, Never>()
    
    private let handleLayer = ColorPickerHandleLayer()
    private let colorLayer = CAGradientLayer.animationDisabled()
    
    override func layout() {
        super.layout()
        self.colorLayer.frame = bounds
        self.updateHandle()
    }
    
    override func mouseDown(with event: NSEvent) {
        self.sendLocation(event.location(in: self))
    }
    override func mouseDragged(with event: NSEvent) {
        self.sendLocation(event.location(in: self))
    }
    
    private func sendLocation(_ location: CGPoint) {
        self.opacityPublisher.send((location.y / bounds.height).clamped(0...1))
    }
    
    private func updateColorLayer() {
        self.colorLayer.colors = [color.cgColor.withAlpha(0), color.cgColor.withAlpha(1)]
    }
    
    private func updateHandle() {
        self.handleLayer.color = color.cgColor
        self.handleLayer.frame.center = [bounds.midX, color.alpha * bounds.height]
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.width.equalTo(32)
        }
        self.wantsLayer = true
        self.layer?.addSublayer(colorLayer)
        self.layer?.addSublayer(handleLayer)
        self.layer?.cornerRadius = R.Size.corner
        self.layer?.borderWidth = 1
        self.layer?.borderColor = CGColor.black.withAlpha(0.2)
        self.layer?.backgroundColor = R.Color.transparentBackground.cgColor
    }
}
