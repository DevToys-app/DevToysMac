//
//  ControlStack.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

class Section: NSLoadView {
    var title: String {
        get { titleLabel.stringValue } set { titleLabel.stringValue = newValue }
    }
    var minTitle: Bool = false {
        didSet {
            self.titleStackView.snp.updateConstraints{ make in
                make.height.equalTo(minTitle ? 16 : R.Size.controlHeight)
            }
        }
    }
    
    func setContentView(_ item: NSView) {
        self.contentStackView.addSubview(item)
        item.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
    func addStackItem(_ item: NSView) {
        self.contentStackView.addArrangedSubview(item)
        item.snp.makeConstraints{ make in
            make.right.left.equalToSuperview()
        }
    }
    func addToolbarItem(_ item: NSView) {
        self.titleStackView.addArrangedSubview(item)
    }
    func removeAllToolbarItem() {
        self.titleStackView.subviews.removeAll(where: { $0 !== titleLabel && $0 !== spacer })
    }
    
    convenience init(title: String, items: [NSView] = [], toolbarItems: [NSView] = []) {
        self.init()
        self.title = title
        for item in items { self.addStackItem(item) }
        for toolbarItem in toolbarItems { self.addToolbarItem(toolbarItem) }
    }
    
    private let titleLabel = NSTextField(labelWithString: "Title")
    private let spacer = NSView()
    private let titleStackView = NSStackView()
    private let contentStackView = NSStackView()
    
    override func onAwake() {
        self.addSubview(titleStackView)
        self.titleStackView.orientation = .horizontal
        self.titleStackView.distribution = .fillProportionally
        self.titleStackView.snp.makeConstraints{ make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(R.Size.controlHeight)
        }
        self.addSubview(contentStackView)
        self.contentStackView.distribution = .fillEqually
        self.contentStackView.orientation = .vertical
        self.contentStackView.snp.makeConstraints{ make in
            make.bottom.right.left.equalToSuperview()
            make.top.equalTo(titleStackView.snp.bottom).offset(8)
        }
        
        self.titleStackView.addArrangedSubview(titleLabel)
        self.titleStackView.addArrangedSubview(spacer)
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
    }
}
