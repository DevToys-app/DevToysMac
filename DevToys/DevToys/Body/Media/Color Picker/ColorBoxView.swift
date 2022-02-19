//
//  ColorBoxView.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

final class ColorBoxView: NSLoadView {
    let valuePublisher = PassthroughSubject<(saturation: CGFloat, brightness: CGFloat), Never>()
    
    var color: Color = .default { didSet { self.updateHandle(); self.updateHue() } }
    
    private let hueLayer = CAGradientLayer.animationDisabled()
    private let handleLayer = ColorPickerHandleLayer()
    private let brightnessLayer = CAGradientLayer.animationDisabled()
    
    override func mouseDown(with event: NSEvent) {
        self.sendLocation(event.location(in: self))
    }
    override func mouseDragged(with event: NSEvent) {
        self.sendLocation(event.location(in: self))
    }
    
    private func sendLocation(_ location: CGPoint) {
        let sb = location / bounds.size.convertToPoint()
        self.valuePublisher.send((saturation: sb.x.clamped(0...1), brightness: sb.y.clamped(0...1)))
    }
    
    private func updateHue() {
        self.hueLayer.colors = [CGColor.white, NSColor(colorSpace: .current, hue: color.hue, saturation: 1, brightness: 1, alpha: 1).cgColor]
    }
    
    private func updateHandle() {
        let centerX = color.saturation * bounds.width
        let centerY = color.brightness * bounds.height
        
        self.handleLayer.color = color.cgColor
        self.handleLayer.frame.center = bounds.origin + [centerX, centerY]
    }
    
    override func layout() {
        super.layout()
        self.hueLayer.frame = bounds
        self.brightnessLayer.frame = bounds
        self.updateHandle()
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(hueLayer)
        self.layer?.addSublayer(brightnessLayer)
        self.layer?.addSublayer(handleLayer)
        self.layer?.cornerRadius = R.Size.corner
        self.layer?.borderWidth = 1
        self.layer?.borderColor = CGColor.black.copy(alpha: 0.2)!
        
        self.hueLayer.startPoint = [0, 0.5]
        self.hueLayer.endPoint = [1, 0.5]
        
        self.brightnessLayer.startPoint = [0.5, 1]
        self.brightnessLayer.endPoint = [0.5, 0]
        self.brightnessLayer.colors = [CGColor.clear, CGColor.black]
    }
}

