//
//  TextField.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

final class TextField: NSLoadView {
    var string: String {
        get { textField.textField.stringValue } set { textField.textField.stringValue = newValue; copyButton.stringContent = newValue }
    }
    var changeStringPublisher: AnyPublisher<String, Never> {
        textField.textField.changeStringPublisher
    }
    var endEditingStringPublisher: AnyPublisher<String, Never> {
        textField.textField.endEditingStringPublisher
    }
    var showCopyButton = false {
        didSet { copyButton.isHidden = !showCopyButton }
    }
    var isEditable: Bool {
        get { textField.textField.isEditable } set { textField.textField.isEditable = newValue }
    }
    
    convenience init(showCopyButton: Bool) {
        self.init()
        self.setup(showCopyButton: showCopyButton)
    }
    
    private func setup(showCopyButton: Bool) {
        self.showCopyButton = showCopyButton
    }
    
    private let textField = DotNetTextField()
    private let stackView = NSStackView()
    private let copyButton = CopySectionButton(hasTitle: false)
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
        self.addSubview(stackView)
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(textField)
        self.stackView.addArrangedSubview(copyButton)
        
        self.textField.snp.makeConstraints{ make in
            make.height.equalToSuperview()
        }
    }
}

final private class DotNetTextField: NSLoadStackView {
    let textField = CustomFocusRingTextField()
    let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
        let focusRingBounds = CGRect(origin: bounds.origin - textField.frame.origin, size: bounds.size)
        self.textField.focusRingBounds = focusRingBounds
    }
    
    override func updateLayer() {
        self.backgroundLayer.update()
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        
        self.spacing = 0
        self.edgeInsets = .init(x: 12, y: 0)
        self.addArrangedSubview(textField)
        self.addArrangedSubview(NSView())
        self.textField.font = .systemFont(ofSize: 12)
    }
}

final class CustomFocusRingTextField: NSLoadTextField {
    var focusRingBounds: CGRect = .zero {
        didSet { self.noteFocusRingMaskChanged() }
    }
    
    override func drawFocusRingMask() { focusRingPath().fill() }
    override var focusRingMaskBounds: NSRect { focusRingBounds }
    
    public override func mouseDown(with event: NSEvent) {
        self.selectText(nil)
    }
    
    private func focusRingPath() -> NSBezierPath {
        NSBezierPath(roundedRect: focusRingBounds, xRadius: R.Size.corner, yRadius: R.Size.corner)
    }
    
    override func onAwake() {
        self.isBezeled = false
        self.isBordered = false
        self.bezelStyle = .roundedBezel
        self.drawsBackground = false
        self.backgroundColor = nil
    }
}

