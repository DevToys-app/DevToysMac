//
//  Separator.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class SeparatorView: NSLoadView {
    private let separatorLayer = CALayer.animationDisabled()
    
    public override func layout() {
        super.layout()
        self.separatorLayer.frame = bounds
    }
    
    public override func updateLayer() {
        self.separatorLayer.backgroundColor = NSColor.textColor.withAlphaComponent(0.1).cgColor
    }
    
    override public func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(separatorLayer)
        
        self.snp.makeConstraints{ make in
            make.height.equalTo(1)
        }
    }
}

