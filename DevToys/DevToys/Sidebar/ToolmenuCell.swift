//
//  ToolmenuCell.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class ToolmenuCell: NSLoadView {
    
    static let height: CGFloat = 36
    
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
            make.size.equalTo(16)
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(titleLabel)
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.titleLabel.snp.makeConstraints{ make in
            make.left.equalTo(self.iconView.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
    }
}
