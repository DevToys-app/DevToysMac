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
    var placeholder: String? {
        get { textField.textField.placeholderString } set { textField.textField.placeholderString = newValue }
    }
    
    var changeStringPublisher: AnyPublisher<String, Never> {
        textField.textField.changeStringPublisher
    }
    var endEditingStringPublisher: AnyPublisher<String, Never> {
        textField.textField.endEditingStringPublisher
    }
    var isError: Bool { get { textField.isError } set { textField.isError = newValue } }
    var font: NSFont? { get { textField.textField.font } set { textField.textField.font = newValue } }
    var showCopyButton = false { didSet { copyButton.isHidden = !showCopyButton } }
    var isEditable: Bool = true { didSet { textField.textField.isEditable = isEditable } }
    
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
        self.textField.textField.lineBreakMode = .byTruncatingTail
        self.stackView.addArrangedSubview(copyButton)
        
        self.textField.snp.makeConstraints{ make in
            make.height.equalToSuperview()
        }
    }
}

final private class DotNetTextField: NSLoadView {
    let textField = CustomFocusRingTextField()
    let backgroundLayer = ControlErrorBackgroundLayer.animationDisabled()
    var isError = false { didSet { needsDisplay = true } }
    
    override func layout() {
        self.backgroundLayer.frame = bounds
        let textFieldFrame = CGRect(originX: 8, centerY: bounds.midY, size: [bounds.width - 16, textField.intrinsicContentSize.height])
        
        let focusRingBounds = CGRect(origin: bounds.origin - textFieldFrame.origin, size: bounds.size)
        self.textField.focusRingBounds = focusRingBounds
        self.textField.frame = textFieldFrame
        super.layout()
    }
    
    
    override func updateLayer() {
        self.backgroundLayer.update(isError: isError)
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        
        self.addSubview(textField)
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

