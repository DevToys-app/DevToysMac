//
//  HueBarView.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

final class HueBarView: NSLoadView {
    
    var color: Color = .default { didSet { self.updateHandle() } }
    let huePublisher = PassthroughSubject<CGFloat, Never>()
    
    private let handleLayer = ColorPickerHandleLayer()
    private let hueLayer = CAGradientLayer.animationDisabled()
    
    override func mouseDown(with event: NSEvent) {
        self.sendLocation(event.location(in: self))
    }
    override func mouseDragged(with event: NSEvent) {
        self.sendLocation(event.location(in: self))
    }
    
    private func sendLocation(_ location: CGPoint) {
        huePublisher.send((location.y / bounds.height).clamped(0...1))
    }
    
    private func updateHandle() {
        self.handleLayer.color = Color(hue: color.hue, saturation: 1, brightness: 1, alpha: 1).cgColor
        self.handleLayer.frame.center = [bounds.midX, color.hue * bounds.height]
    }
    
    override func layout() {
        super.layout()
        self.hueLayer.frame = bounds
        self.updateHandle()
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.width.equalTo(32)
        }
        self.wantsLayer = true
        self.layer?.addSublayer(hueLayer)
        self.layer?.addSublayer(handleLayer)
        self.layer?.cornerRadius = R.Size.corner
        self.layer?.borderWidth = 1
        self.layer?.borderColor = CGColor.black.withAlpha(0.2)
        
        self.hueLayer.colors = hueColors
    }
}

private let hueColors = stride(from: 0, to: 1, by: 0.1).map{ NSColor(colorSpace: .current, hue: CGFloat($0), saturation: 1, brightness: 1, alpha: 1).cgColor }
