//
//  AllToolCollectionItemView+.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class AllToolCollectionItemViewController: NSViewController {
    private let scrollView = NSScrollView()
    private let collectionView = NSCollectionView()
    
    private let allTools: [ToolType] = [
        .jsonYamlConvertor, .numberBaseConvertor,
        .htmlDecoder, .urlDecoder, .base64Decoder, .jwtDecoder,
        .jsonFormatter,
        .hashGenerator, .uuidGenerator, .leremIpsumGenerator,
        .caseConverter, .regexTester, .textComparer, .markdownPreview,
        .colorBlindnessSimulator, .imageCompressor
    ]
    
    override func loadView() {
        self.view = scrollView
        self.scrollView.documentView = collectionView
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = [125, 230]
        flowLayout.sectionInset = NSEdgeInsets(top: 32, left: 42, bottom: 32, right: 42)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isSelectable = true
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.register(AllToolCollectionItem.self, forItemWithIdentifier: AllToolCollectionItem.identifier)
    }
}

extension AllToolCollectionItemViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        self.allTools.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: AllToolCollectionItem.identifier, for: indexPath) as! AllToolCollectionItem
        let tool = self.allTools[indexPath.item]
        
        item.cell.icon = tool.toolListIcon
        item.cell.title = tool.toolListTitle
        item.cell.toolDescription = tool.toolDescription
        
        return item
    }
}

extension AllToolCollectionItemViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first?.item else { return }
        appModel.toolType = self.allTools[index]
        self.collectionView.deselectAll(nil)
    }
}

final private class AllToolCollectionItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("AllToolCollectionItem")
    
    let cell = AllToolCell()
    
    override func loadView() { self.view = cell }
}

final private class AllToolCell: NSLoadView {
    var icon: NSImage? {
        get { iconView.iconView.image } set { iconView.iconView.image = newValue }
    }
    var title: String {
        get { titleLabel.stringValue } set { titleLabel.stringValue = newValue }
    }
    var toolDescription: String {
        get { descriptionLabel.stringValue } set { descriptionLabel.stringValue = newValue }
    }
    
    private let iconView = AllToolCellIconView()
    private let iconContainer = NSView()
    
    private let labelStack = NSStackView()
    private let titleLabel = NSTextField(labelWithString: "Hello World")
    private let descriptionLabel = NSTextField(labelWithString: "Here you can see the next type of development environment.")
    private let backgroundLayer = CALayer.animationDisabled()
    private var isMouseInside = false { didSet { needsDisplay = true } }
    
    override func updateLayer() {
        self.backgroundLayer.areAnimationsEnabled = true
        
        if isMouseInside {
            self.backgroundLayer.backgroundColor = NSColor.textColor.withAlphaComponent(0.1).cgColor
        } else {
            self.backgroundLayer.backgroundColor = NSColor.textColor.withAlphaComponent(0.05).cgColor
        }
        
        self.backgroundLayer.areAnimationsEnabled = false
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.isMouseInside = true
    }
    override func mouseExited(with event: NSEvent) {
        self.isMouseInside = false
    }
    
    override func updateTrackingAreas() {
        self.trackingAreas.forEach(removeTrackingArea(_:))
        self.addTrackingRect(bounds, owner: self, userData: nil, assumeInside: true)
    }
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        self.backgroundLayer.cornerRadius = R.Size.corner
        self.backgroundLayer.shadowRadius = 2
        self.backgroundLayer.shadowOpacity = 0.2
        self.backgroundLayer.shadowOffset = [0, 2]
        
        self.addSubview(iconContainer)
        self.iconContainer.snp.makeConstraints{ make in
            make.right.left.top.equalToSuperview()
            make.size.equalTo(125)
        }
        
        self.iconContainer.addSubview(iconView)
        self.iconView.snp.makeConstraints{ make in
            make.size.equalTo(74)
            make.center.equalToSuperview()
        }
        
        self.addSubview(labelStack)
        self.labelStack.orientation = .vertical
        self.labelStack.spacing = 4
        self.labelStack.alignment = .left
        self.labelStack.snp.makeConstraints{ make in
            make.right.left.equalToSuperview().inset(10)
            make.top.equalTo(iconContainer.snp.bottom)
        }
        
        self.labelStack.addArrangedSubview(titleLabel)
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.font = .systemFont(ofSize: 10.5, weight: .medium)
        
        self.labelStack.addArrangedSubview(descriptionLabel)
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        self.descriptionLabel.font = .systemFont(ofSize: 10)
        self.descriptionLabel.textColor = .secondaryLabelColor
    }
}

final private class AllToolCellIconView: NSLoadView {
    let iconView = NSImageView()
    private let backgroundLayer = CALayer.animationDisabled()
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func updateLayer() {
        self.backgroundLayer.backgroundColor = NSColor.quaternaryLabelColor.cgColor
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        self.backgroundLayer.cornerRadius = R.Size.corner
        self.backgroundLayer.shadowRadius = 2
        self.backgroundLayer.shadowOpacity = 0.2
        self.backgroundLayer.shadowOffset = [0, 2]
        
        self.addSubview(iconView)
        self.iconView.image = R.Image.ToolList.base64Coder
        self.iconView.contentTintColor = .textColor
        self.iconView.snp.makeConstraints{ make in
            make.size.equalTo(40)
            make.center.equalToSuperview()
        }
    }
}

