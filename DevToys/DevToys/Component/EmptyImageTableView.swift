//
//  EmptyImageTableView.swift
//  DevToys
//
//  Created by yuki on 2022/02/22.
//

import CoreUtil

open class EmptyImageTableView: NSLoadTableView {
    
    open var emptyView: NSView? {
        get { emptyViewPlaceholder.contentView } set { emptyViewPlaceholder.contentView = newValue }
    }
    
    private let emptyViewPlaceholder = NSPlaceholderView()
        
    open override func didRemove(_ rowView: NSTableRowView, forRow row: Int) {
        super.didRemove(rowView, forRow: row)
        self.updateRowCount()
    }
    open override func didAdd(_ rowView: NSTableRowView, forRow row: Int) {
        super.didAdd(rowView, forRow: row)
        self.updateRowCount()
    }
    
    private func updateRowCount() {
        if numberOfRows == 0 {
            self.emptyViewPlaceholder.isHidden = false
        } else {
            self.emptyViewPlaceholder.isHidden = true
        }
    }
    private func commonInit() {
        self.addSubview(emptyViewPlaceholder)
        self.emptyViewPlaceholder.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        self.updateRowCount()
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}

extension EmptyImageTableView {
    public func setFileDropEmptyView(_ title: String = "Drop Files Here".localized()) {
        self.emptyView = DropIndicatorView(title: title)
    }
}

final class DropIndicatorView: NSLoadStackView {
    private let imageView = NSImageView(image: R.Image.drop)
    private let titleLabel = NSTextField(labelWithString: "Title")
    
    convenience init(title: String) {
        self.init()
        self.titleLabel.stringValue = title
    }
    
    override func onAwake() {
        self.unregisterDraggedTypes()
        self.alignment = .centerX
        self.orientation = .vertical
        self.addArrangedSubview(imageView)
        self.addArrangedSubview(titleLabel)
    }
}
