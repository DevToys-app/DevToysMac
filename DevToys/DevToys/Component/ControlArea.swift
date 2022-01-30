//
//  ComponentBaseView.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class ControlArea: NSLoadView {
    var control: NSView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let control = control { self.stackView.addArrangedSubview(control) }
        }
    }
    
    var icon: NSImage? {
        get { iconView.image } set { iconView.image = newValue; iconView.isHidden = icon == nil }
    }
    var title: String {
        get { titleLabel.stringValue } set { titleLabel.stringValue = newValue }
    }
    var message: String? = "Message" {
        didSet { messageLabel.isHidden = message == nil; messageLabel.stringValue = message ?? "" }
    }
    
    convenience init(icon: NSImage? = nil, title: String, message: String? = nil, control: NSView) {
        self.init()
        self.setup(icon: icon, title: title, message: message, control: control)
    }
    
    private func setup(icon: NSImage?, title: String, message: String?, control: NSView) {
        self.icon = icon
        self.title = title
        self.message = message
        self.control = control
    }
    
    private let iconView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "Title")
    private let messageLabel = NSTextField(labelWithString: "Message")
    private let titleStack = NSStackView()
    private let stackView = NSStackView()
    private let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    
    override func updateLayer() {
        self.backgroundLayer.update()
    }
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        self.snp.makeConstraints{ make in
            make.height.equalTo(64)
        }
        
        self.addSubview(stackView)
        self.stackView.orientation = .horizontal
        self.stackView.edgeInsets = .init(x: 16, y: 0)
        self.stackView.spacing = 16
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(iconView)
        self.iconView.image = R.Image.ToolList.base64Coder
        self.iconView.snp.makeConstraints{ make in
            make.size.equalTo(24)
        }
        
        self.stackView.addArrangedSubview(titleStack)
        self.titleStack.orientation = .vertical
        self.titleStack.spacing = 4
        self.titleStack.alignment = .left
        
        self.titleStack.addArrangedSubview(titleLabel)
        self.titleLabel.font = NSFont.systemFont(ofSize: R.Size.controlTitleFontSize)
        
        self.titleStack.addArrangedSubview(messageLabel)
        self.messageLabel.font = NSFont.systemFont(ofSize: R.Size.controlFontSize)
        self.messageLabel.textColor = .secondaryLabelColor
        self.messageLabel.lineBreakMode = .byTruncatingTail
        
        self.stackView.addArrangedSubview(NSView())
    }
}
