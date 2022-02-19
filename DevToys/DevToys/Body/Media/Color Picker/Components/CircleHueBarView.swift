//
//  CircleHueBarView.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil


final class CircleHueBarView: NSLoadView {
    var color: Color = .default { didSet { self.updateHandle() } }
    let huePublisher = PassthroughSubject<CGFloat, Never>()
    let placeholder = NSPlaceholderView()
    
    private let handleLayer = ColorPickerHandleLayer()
    private let maskLayer = CAShapeLayer.animationDisabled()
    private let borderLayer = CAShapeLayer.animationDisabled()
    private let hueLayer = CAGradientLayer.animationDisabled()
    
    override func mouseDown(with event: NSEvent) {
        self.sendLocation(event.location(in: self))
    }
    override func mouseDragged(with event: NSEvent) {
        self.sendLocation(event.location(in: self))
    }
    
    private func sendLocation(_ location: CGPoint) {
        let delta = bounds.center - location
        let radius = atan2(delta.y, delta.x) / (2 * .pi) + 0.5
        print(delta, radius)
        huePublisher.send(radius.clamped(0...1))
    }
    
    private func updateHandle() {
        self.handleLayer.color = Color(hue: color.hue, saturation: 1, brightness: 1, alpha: 1).cgColor
        let radius = (color.hue) * 2 * .pi
        self.handleLayer.frame.center = bounds.center + [cos(radius), sin(radius)] * (self.bounds.size.convertToPoint()/2 - [R.ColorPicker.barWidth, R.ColorPicker.barWidth]/2)
    }
    
    override func layout() {
        super.layout()
        self.hueLayer.frame = bounds
        self.maskLayer.path = CGPath(ellipseIn: bounds.slimmed(by: R.ColorPicker.barWidth/2), transform: nil)
        self.borderLayer.path = self.maskLayer.path!
            .copy(strokingWithWidth: R.ColorPicker.barWidth-1, lineCap: CGLineCap.butt, lineJoin: .miter, miterLimit: .infinity)
        self.updateHandle()
        
        self.placeholder.frame = bounds.slimmed(by: 50)
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.snp.makeConstraints{ make in
            make.size.equalTo(R.ColorPicker.pickerHeight)
        }
        
        self.layer?.addSublayer(hueLayer)
        self.layer?.addSublayer(borderLayer)
        self.layer?.addSublayer(handleLayer)
        self.hueLayer.colors = hueColors
        self.hueLayer.startPoint = [0.5, 0.5]
        self.hueLayer.endPoint = [1, 0.5]
        self.hueLayer.type = .conic
        
        self.hueLayer.mask = maskLayer
        self.maskLayer.lineWidth = R.ColorPicker.barWidth
        self.maskLayer.fillColor = nil
        self.maskLayer.strokeColor = .black
        
        self.borderLayer.lineWidth = 1
        self.borderLayer.fillColor = nil
        self.borderLayer.strokeColor = .black.withAlpha(0.2)
        
        self.addSubview(placeholder)
    }
}
