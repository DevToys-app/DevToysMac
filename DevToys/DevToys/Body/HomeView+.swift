//
//  HomeViewController+.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

class SearchViewController: HomeViewController {
    override func chainObjectDidLoad() {
        self.appModel.$searchQuery.map{ Query($0) }
            .sink{[unowned self] query in self.tools = appModel.toolManager.allTools().filter{ query.matches(to: $0.title) } }
            .store(in: &objectBag)
    }
}

class HomeViewController: NSViewController {
    private let scrollView = NSScrollView()
    private let collectionView = NSCollectionView()
    
    var tools: [Tool] = [] {
        didSet { collectionView.reloadData() }
    }
    
    override func loadView() {
        self.view = scrollView
        self.scrollView.documentView = collectionView
        
        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.itemSize = [125, 230]
        flowLayout.sectionInset = NSEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        flowLayout.minimumInteritemSpacing = 8
        
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.register(ToolCollectionItem.self, forItemWithIdentifier: ToolCollectionItem.identifier)
        self.collectionView.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(onClick)))
    }
    
    @objc private func onClick(_ recognizer: NSGestureRecognizer) {
        guard let indexPath = collectionView.indexPathForItem(at: recognizer.location(in: collectionView)),
              let tool = self.tools.at(indexPath.item)
        else { return }
        
        self.appModel.tool = tool
    }
    
    override func chainObjectDidLoad() {
        self.tools = appModel.toolManager.allTools().filter{ $0.showOnHome }
    }
}

extension HomeViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        self.tools.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: ToolCollectionItem.identifier, for: indexPath) as! ToolCollectionItem
        let tool = self.tools[indexPath.item]
        
        item.cell.icon = tool.icon
        item.cell.title = tool.title
        item.cell.toolDescription = tool.toolDescription
        
        return item
    }
}

final private class ToolCollectionItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("ToolCollectionItem")
    
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
    override func viewDidHide() {
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
        self.iconView.image = R.Image.Tool.base64Coder
        self.iconView.contentTintColor = .textColor
        self.iconView.snp.makeConstraints{ make in
            make.size.equalTo(40)
            make.center.equalToSuperview()
        }
    }
}

