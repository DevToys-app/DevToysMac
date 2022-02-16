//
//  ToolmenuCell.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class ToolCategoryCell: NSLoadView {
    static let height: CGFloat = 28
    
    private let titleLabel = NSTextField(labelWithString: "Title")
    
    override func onAwake() {
        self.addSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlFontSize, weight: .bold)
        self.titleLabel.textColor = .secondaryLabelColor
        self.titleLabel.snp.makeConstraints{ make in
            make.left.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
}

final class ToolMenuCell: NSLoadView {
    static let height: CGFloat = 28
    
    var title: String {
        get { titleLabel.stringValue } set { titleLabel.stringValue = newValue }
    }
    var icon: NSImage? {
        get { iconView.image } set { iconView.image = newValue }
    }
    
    private let titleLabel = NSTextField(labelWithString: "Title")
    private let iconView = NSImageView()
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(Self.height)
        }
        self.addSubview(iconView)
        self.iconView.snp.makeConstraints{ make in
            make.size.equalTo(20)
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(titleLabel)
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
        self.titleLabel.snp.makeConstraints{ make in
            make.left.equalTo(self.iconView.snp.right).offset(8)
            make.right.equalToSuperview().inset(4)
            make.centerY.equalToSuperview()
        }
    }
}
