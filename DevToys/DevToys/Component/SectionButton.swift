//
//  ControlStackButton.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

class SectionButton: NSLoadButton {
    override var title: String { didSet { updateTitle()  } }
    override var image: NSImage? { didSet { iconView.image = image } }
    
    private let titleLabel = NSTextField(labelWithString: "Paste".localized())
    private let iconView = NSImageView(image: R.Image.Tool.convert)
    
    private let stackView = NSStackView()
    private let backgroundLayer = ControlButtonBackgroundLayer.animationDisabled()
    
    override var isHighlighted: Bool { didSet { needsDisplay = true } }
    
    private func updateTitle() {
        titleLabel.stringValue = title
        if title.isEmpty {
            titleLabel.isHidden = true
            self.stackView.distribution = .fillEqually
        } else {
            titleLabel.isHidden = false
        }
    }
    
    override func updateLayer() {
        self.backgroundLayer.update(isHighlighted: isHighlighted)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        updateLayer()
    }
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
        self.wantsLayer = true
        self.isBordered = false
        self.title = ""
        self.layer?.addSublayer(backgroundLayer)
        
        self.snp.makeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
        self.addSubview(stackView)
        self.stackView.spacing = 4
        self.stackView.distribution = .equalCentering
        self.stackView.edgeInsets = .init(x: 8, y: 0)
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(iconView)
        self.iconView.snp.makeConstraints{ make in
            make.size.equalTo(20)
        }
        
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
        self.stackView.addArrangedSubview(titleLabel)
        
        self.updateTitle()
    }
}

extension NSButton {
    convenience init(title: String? = nil, image: NSImage? = nil) {
        self.init()
        self.setup(title: title, image: image)
    }
    
    private func setup(title: String?, image: NSImage?) {
        self.title = title ?? ""
        self.image = image
    }
}
