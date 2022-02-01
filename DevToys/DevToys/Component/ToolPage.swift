//
//  ToolPage.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil
 
class ToolPage: NSLoadView {
    
    var title: String {
        get { titleLabel.stringValue } set { titleLabel.stringValue = newValue }
    }
    
    private let titleLabel = NSTextField(labelWithString: "Title")
    let stackView = NSStackView()
    private let scrollView = NSScrollView()
    
    func addSection(_ title: String, orientation: NSUserInterfaceLayoutOrientation = .vertical, items: [NSView], toolbarItems: [NSView]) {
        let stack = ControlSection(title: title, orientation: orientation, items: items, toolbarItems: toolbarItems)
        self.stackView.addArrangedSubview(stack)
    }
    
    func addSection(_ stack: ControlSection) {
        self.stackView.addArrangedSubview(stack)
    }
    
    func addSection2(_ stack1: ControlSection, _ stack2: ControlSection) {
        let stackView = NSStackView()
        stackView.distribution = .fillEqually
        stackView.orientation = .horizontal
        stackView.addArrangedSubview(stack1)
        stackView.addArrangedSubview(stack2)
        self.stackView.addArrangedSubview(stackView)
    }
    
    private func commonInit() {
        self.addSubview(scrollView)
        self.scrollView.contentView = FlipClipView()
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.scrollView.documentView = stackView
        self.stackView.edgeInsets = NSEdgeInsets(x: 32, y: 20)
        self.stackView.orientation = .vertical
        self.stackView.spacing = 8
        self.stackView.alignment = .left
        self.stackView.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
        }
        
        self.stackView.insertArrangedSubview(titleLabel, at: 0)
        self.stackView.setCustomSpacing(20, after: titleLabel)
        self.titleLabel.font = .systemFont(ofSize: 32, weight: .medium)
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

private class FlipClipView: NSClipView {
    override var isFlipped: Bool { true }
}
