//
//  TagCloudView.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil


final class TagCloudView: NSLoadView {
    let collectionView = NSCollectionView()
    let flowLayout = LeftAlignedCollectionViewFlowLayout()
    let buttonPublisher = PassthroughSubject<Int, Never>()
    let selectPublisher = PassthroughSubject<Int, Never>()
    
    var selectedItem: Int? {
        didSet {
            if let selectedItem = selectedItem {
                collectionView.selectItems(at: [IndexPath(item: selectedItem, section: 0)], scrollPosition: .bottom)
            } else {
                collectionView.deselectAll(nil)
            }
        }
    }
    var isSelectable = false {
        didSet { collectionView.isSelectable = isSelectable; collectionView.reloadData() }
    }
    var items: [String] = ["Hello", "World"] {
        didSet {
            collectionView.reloadData()
            DispatchQueue.main.async {[self] in self.reloadHeight() }
        }
    }
    
    override func layout() {
        self.reloadHeight()
        super.layout()
    }
    
    private func reloadHeight() {
        let collectionViewContentSize = flowLayout.collectionViewContentSize
        self.snp.remakeConstraints{ make in
            make.height.equalTo(collectionViewContentSize.height)
        }
    }
    
    override func onAwake() {
        self.frame.size = [1, 1]
        flowLayout.scrollDirection = .vertical
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.invalidateLayout()
        collectionView.collectionViewLayout = flowLayout
        
        self.addSubview(collectionView)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(TagCloudItem.self, forItemWithIdentifier: TagCloudItem.identifier)
        self.collectionView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

extension TagCloudView: NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        selectPublisher.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: TagCloudItem.identifier, for: indexPath) as! TagCloudItem
        
        item.cell.isEnabled = !isSelectable
        item.cell.actionPublisher
            .sink{ self.buttonPublisher.send(indexPath.item) }.store(in: &item.objectBag)
        
        item.cell.label.stringValue = items[indexPath.item]
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let label = NSTextField(labelWithString: items[indexPath.item])
        label.font = .systemFont(ofSize: 14)
        label.sizeToFit()
        return label.frame.size + [16, 12]
    }
}

final private class TagCloudItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: "TagCloudItem")
    override var isSelected: Bool { didSet { cell.isSelected = isSelected } }
    
    class Cell: NSLoadButton {
        let label = NSTextField(labelWithString: "")
        let backgroundLayer = ControlButtonBackgroundLayer.animationDisabled()
        var isSelected: Bool = false { didSet { needsDisplay = true } }
        
        override func layout() {
            super.layout()
            self.backgroundLayer.frame = bounds
        }
        override func updateLayer() {
            backgroundLayer.update(isHighlighted: isHighlighted)
            
            backgroundLayer.areAnimationsEnabled = true
            if isSelected {
                backgroundLayer.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.5).cgColor
                backgroundLayer.borderColor = NSColor.controlAccentColor.cgColor
                backgroundLayer.borderWidth = 1
            } else {
                backgroundLayer.borderWidth = 0
            }
            backgroundLayer.areAnimationsEnabled = false
        }
        
        override func onAwake() {
            self.wantsLayer = true
            self.title = ""
            self.isBordered = false
            self.layer?.addSublayer(backgroundLayer)
            
            self.addSubview(label)
            self.label.alignment = .center
            self.label.snp.makeConstraints{ make in
                make.left.right.equalToSuperview().inset(8)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    let cell = Cell()
    
    override func loadView() { self.view = cell }
}


final class LeftAlignedCollectionViewFlowLayout: NSCollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .item {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        return attributes
    }
}

