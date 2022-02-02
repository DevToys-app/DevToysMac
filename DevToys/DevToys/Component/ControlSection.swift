//
//  ControlStack.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

class ControlSection: NSLoadView {
    func addStackItem(_ item: NSView) {
        self.contentStackView.addArrangedSubview(item)
    }
    func addToolbarItem(_ item: NSView) {
        self.toolbarStackView.addArrangedSubview(item)
    }
    func removeAllToolbarItem() {
        self.toolbarStackView.subviews.removeAll()
    }
    
    var orientation: NSUserInterfaceLayoutOrientation {
        get { contentStackView.orientation } set { contentStackView.orientation = newValue }
    }
    var title: String {
        get { titleLabel.stringValue } set { titleLabel.stringValue = newValue }
    }
    var minTitle: Bool = false {
        didSet {
            self.titleStackView.snp.remakeConstraints{ make in
                if minTitle {
                    make.height.equalTo(16)
                } else {
                    make.height.equalTo(36)
                }
            }
        }
    }
    
    convenience init(title: String, orientation: NSUserInterfaceLayoutOrientation = .vertical, items: [NSView] = [], toolbarItems: [NSView] = []) {
        self.init()
        self.title = title
        self.orientation = orientation
        for item in items { self.addStackItem(item) }
        for toolbarItem in toolbarItems { self.addToolbarItem(toolbarItem) }
    }
    
    private let titleLabel = NSTextField(labelWithString: "Title")
    
    private let titleStackView = NSStackView()
    private let toolbarStackView = NSStackView()
    let contentStackView = NSStackView()
    let stackView = NSStackView()
    
    override func onAwake() {
        self.addSubview(stackView)
        self.stackView.orientation = .vertical
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(titleStackView)
        self.stackView.addArrangedSubview(contentStackView)
        self.contentStackView.distribution = .fillEqually
        
        self.titleStackView.orientation = .horizontal
        self.titleStackView.alignment = .bottom
        self.titleStackView.snp.makeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
        
        self.titleStackView.addArrangedSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
        
        self.titleStackView.addArrangedSubview(NSView())
        self.titleStackView.distribution = .fillProportionally
        self.titleStackView.addArrangedSubview(toolbarStackView)
    }
}
