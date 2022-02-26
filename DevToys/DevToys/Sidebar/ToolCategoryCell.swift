//
//  ToolCategoryCell.swift
//  DevToys
//
//  Created by yuki on 2022/02/16.
//

import CoreUtil

final class ToolCategoryCell: NSLoadView {
    static let height: CGFloat = 21
    
    var title: String {
        get { titleLabel.stringValue } set { titleLabel.stringValue = newValue }
    }
    
    private let titleLabel = NSTextField(labelWithString: "Title")
    
    override func onAwake() {
        self.addSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        self.titleLabel.textColor = .tertiaryLabelColor
        self.titleLabel.snp.makeConstraints{ make in
            make.left.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
}

