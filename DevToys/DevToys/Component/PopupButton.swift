//
//  PopupButton.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

protocol TextItem: CaseIterable, Equatable {
    var title: String { get }
}

extension RawRepresentable where RawValue == String {
    var title: String { rawValue }
}

final class EnumPopupButton<Item: TextItem>: PopupButton {
    
    var selectedItem: Item? {
        didSet { selectedMenuTitle = selectedItem?.title }
    }
    let itemPublisher = PassthroughSubject<Item, Never>()
    
    override func makeMenuItems() -> [NSMenuItem] {
        Item.allCases.map{ item in
            NSMenuItem(title: item.title, isSelected: selectedItem == item, action: {
                self.itemPublisher.send(item)
            })
        }
    }
}

class PopupButton: NSLoadButton {

    var menuItems = [NSMenuItem]()
    var selectedMenuTitle: String? { didSet { self.titleLabel.stringValue = selectedMenuTitle ?? "No selection".localized() } }
    
    func makeMenuItems() -> [NSMenuItem] { menuItems }
    
    private let titleLabel = NSTextField(labelWithString: "No selection".localized())
    private let pulldownIndicator = NSImageView(image: R.Image.Tool.convert)
    private let stackView = NSStackView()
    private let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    
    override var isHighlighted: Bool { didSet { needsDisplay = true } }
    
    override func updateLayer() {
        self.backgroundLayer.update()
    }
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func mouseDown(with event: NSEvent) {
        let menu = NSMenu()
        
        for item in makeMenuItems() { menu.addItem(item) }
        
        menu.minimumWidth = self.bounds.width
        menu.popUp(positioning: menu.items.first(where: { $0.isSelected }), at: .zero, in: self)
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.isBordered = false
        self.title = ""
        self.layer?.addSublayer(backgroundLayer)
        
        self.snp.makeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
        self.addSubview(stackView)
        self.stackView.spacing = 4
        self.stackView.edgeInsets = .init(x: 8, y: 0)
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
        self.stackView.addArrangedSubview(titleLabel)
        
        self.stackView.addArrangedSubview(pulldownIndicator)
        self.pulldownIndicator.snp.makeConstraints{ make in
            make.size.equalTo(18)
        }
    }
}
