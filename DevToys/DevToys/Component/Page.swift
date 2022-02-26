//
//  ToolPage.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil
 
class Page: NSLoadView { 
    
    let stackView = NSStackView()
    let scrollView = NSScrollView()
    
    func addSection(_ section: NSView, fillWidth: Bool = true) {
        self.stackView.addArrangedSubview(section)
        if fillWidth {
            section.snp.makeConstraints{ make in
                make.right.left.equalToSuperview().inset(16)
            }
        }
    }
    
    @discardableResult
    func addSection2(_ stack1: NSView, _ stack2: NSView) -> NSStackView {
        let stackView = NSStackView()
        stackView.distribution = .fillEqually
        stackView.orientation = .horizontal
        stackView.alignment = .top
        stackView.addArrangedSubview(stack1)
        stackView.addArrangedSubview(stack2)
        self.addSection(stackView)
        return stackView
    }
    
    private func commonInit() {
        self.addSubview(scrollView)
        self.scrollView.contentView = FlipClipView()
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.stackView.edgeInsets = NSEdgeInsets(x: 16, y: 16)
        self.stackView.orientation = .vertical
        self.stackView.alignment = .left
        self.scrollView.documentView = stackView
        
        self.stackView.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.right.left.equalToSuperview()
        }
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
