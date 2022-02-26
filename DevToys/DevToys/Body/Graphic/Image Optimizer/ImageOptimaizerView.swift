//
//  Image Optimizer.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

final class ImageOptimizerViewController: NSViewController {
    private let cell = ImageOptimizerView()
    
    @Observable var tasks = [ImageOptimizeTask]()
    @RestorableState("imop.level") var level = OptimizeLevel.medium
    @RestorableState("imop.override") var overrideSource = false
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.cell.urlPublisher
            .sink{[unowned self] in processFiles($0) }.store(in: &objectBag)
        self.cell.deletePublisher
            .sink{[unowned self] in deleteResult($0) }.store(in: &objectBag)
        self.cell.levelPicker.itemPublisher
            .sink{[unowned self] in self.level = $0 }.store(in: &objectBag)
        self.cell.overrideSwiftch.isOnPublisher
            .sink{[unowned self] in self.overrideSource = $0 }.store(in: &objectBag)
        
        self.$tasks
            .sink{[unowned self] in self.cell.tasks = $0 }.store(in: &objectBag)
        self.$level
            .sink{[unowned self] in self.cell.levelPicker.selectedItem = $0 }.store(in: &objectBag)
        self.$overrideSource
            .sink{[unowned self] in self.cell.overrideSwiftch.isOn = $0 }.store(in: &objectBag)
        
        self.cell.listView.menu = NSMenu() => { menu in
            menu.addItem(title: "Open in Finder".localized()) { [self] in
                if let task = tasks.at(cell.listView.clickedRow) {
                    NSWorkspace.shared.activateFileViewerSelecting([task.url])
                }
            }
        }
    }
    
    private func deleteResult(_ indexes: [Int]) {
        indexes.reversed().forEach{
            if case .pending = self.tasks[$0].result.state {} else {
                self.tasks.remove(at: $0)
            }
        }
    }
    private func processFiles(_ urls: [URL]) {
        do {
            self.tasks.append(contentsOf: try urls.compactMap{
                try ImageOptimizer.optimize($0, override: overrideSource, optimizeLevel: level)
            })
        } catch ImageOptimizeError.noAccessToDirectory(let url) {
            Toast(message: "No access to directory '\(url.lastPathComponent)'", color: .systemRed).show()
        } catch ImageOptimizeError.unkownType(let fileExtension) {
            Toast(message: "Unsupported file type '\(fileExtension)'", color: .systemRed).show()
        } catch {
            print(error)
            Toast(message: "Unkown Error", color: .systemRed).show()
        }
    }
}


final private class ImageOptimizerView: Page {
    let overrideSwiftch = NSSwitch()
    let listView = ImageListView.list()
    let listScrollView = NSScrollView()
    
    let urlPublisher = PassthroughSubject<[URL], Never>()
    let deletePublisher = PassthroughSubject<[Int], Never>()
    
    var tasks: [ImageOptimizeTask] = [] {
        didSet {
            listView.reloadData()
            self.subviews.forEach{ $0.needsLayout = true }
        }
    }
    let levelPicker = EnumPopupButton<OptimizeLevel>()
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .delete: deletePublisher.send(self.listView.selectedRowIndexes.map{ $0 })
        default: super.keyDown(with: event)
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard.canReadTypes([.URL, .fileURL, .fileContents]) { return .copy }
        return .none
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return false
        }
        urlPublisher.send(urls)
        return true
    }
    
    override func layout() {
        listScrollView.snp.remakeConstraints{ make in
            make.height.equalTo(max(200, self.frame.height - 260))
        }
        super.layout()
    }
    
    override func onAwake() {
        self.registerForDraggedTypes([.URL, .fileURL, .fileContents])
        
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.paramators, title: "Optimize Level".localized(), control: levelPicker),
            Area(icon: R.Image.export, title: "Override original file".localized(), control: overrideSwiftch)
        ]))
        
        self.listScrollView.documentView = listView
        
        self.addSection(Section(title: "Images".localized(), items: [listScrollView]))
        self.listView.snp.makeConstraints{ make in
            make.height.greaterThanOrEqualTo(1) // AppKitのバグ対処用
        }
        
        self.listView.allowsMultipleSelection = true
        self.listView.delegate = self
        self.listView.dataSource = self
    }
}

extension ImageOptimizerView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int { tasks.count }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 32 }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = ImageOptimizeCell()
        let task = tasks[row]
        cell.titleLabel.stringValue = task.title
        cell.doneCheckView.isHidden = true
        cell.indicator.isHidden = false
        
        task.result
            .receive(on: .main)
            .sink({
                cell.doneCheckView.isHidden = false
                cell.indicator.isHidden = true
                cell.resultLabel.stringValue = $0
            }, {
                cell.doneCheckView.isHidden = false
                cell.indicator.isHidden = true
                cell.resultLabel.stringValue = "\($0)"
                cell.resultLabel.textColor = .red
            })
        
        return cell
    }
}

final private class ImageListView: NSLoadTableView {
    private let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    override func updateLayer() {
        self.backgroundLayer.update()
    }
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
    }
}

final private class ImageOptimizeCell: NSLoadView {
    let titleLabel = NSTextField(labelWithString: "Title.png")
    let resultLabel = NSTextField(labelWithString: "Optimizing...")
    let indicator = NSProgressIndicator()
    let stackView = NSStackView()
    let doneCheckView = NSImageView()
    
    override func onAwake() {
        self.addSubview(stackView)
        self.stackView.edgeInsets = .init(x: 8, y: 8)
        self.stackView.distribution = .fillProportionally
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(doneCheckView)
        self.doneCheckView.isHidden = true
        self.doneCheckView.image = R.Image.check
        self.doneCheckView.snp.makeConstraints{ make in
            make.size.equalTo(16)
        }
        
        self.stackView.addArrangedSubview(indicator)
        self.indicator.style = .spinning
        self.indicator.startAnimation(nil)
        self.indicator.snp.makeConstraints{ make in
            make.size.equalTo(14)
        }
        
        self.stackView.addArrangedSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
        
        self.stackView.addArrangedSubview(resultLabel)
        self.resultLabel.alignment = .right
        self.resultLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
    }
}


extension NSPasteboard {
    func canReadTypes(_ types: [PasteboardType]) -> Bool {
        self.canReadItem(withDataConformingToTypes: types.map{ $0.rawValue })
    }
}
