//
//  MovieToGifView.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil
import CoreGraphics
import Quartz

final class GifConverterViewController: NSViewController {
    private let cell = GifConverterView()
    
    @Observable var tasks = [GifConvertTask]()
    @RestorableState("gif.width") var width = 640.0
    @RestorableState("gif.fps") var fps = 10
    @RestorableState("gif.removeSource") var removeSource = false
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        self.$tasks
            .sink{[unowned self] in cell.listView.convertTasks = $0 }.store(in: &objectBag)
        self.$width
            .sink{[unowned self] in cell.widthField.value = $0 }.store(in: &objectBag)
        self.$fps
            .sink{[unowned self] in cell.fpsField.value = CGFloat($0) }.store(in: &objectBag)
        self.$removeSource
            .sink{[unowned self] in cell.removeFileSwitch.isOn = $0 }.store(in: &objectBag)
        
        self.cell.widthField.publisher
            .sink{[unowned self] in self.width = $0 }.store(in: &objectBag)
        self.cell.fpsField.publisher
            .sink{[unowned self] in self.fps = Int($0) }.store(in: &objectBag)
        self.cell.removeFileSwitch.isOnPublisher
            .sink{[unowned self] in self.removeSource = $0 }.store(in: &objectBag)
        
        self.cell.dropPublisher
            .sink{[unowned self] in handleDrop($0) }.store(in: &objectBag)
        self.cell.listView.removePublisher
            .sink{[unowned self] in removeItems($0) }.store(in: &objectBag)
    }
    
    private func removeItems(_ indexSet: IndexSet) {
        for index in indexSet.reversed() {
            self.tasks.remove(at: index)
        }
    }
    
    private func handleDrop(_ urls: [URL]) {
        var newTasks = [Promise<GifConvertTask, Never>]()
        
        for url in urls {
            let destinationURL = url.deletingPathExtension().appendingPathExtension("gif")
            let options = GifConvertOptions(thumbsize: GifConvertTaskCell.thumbnailImageSize, width: width, fps: fps, removeSourceFile: removeSource)
            let task = GifConverter.convert(url, options: options, to: destinationURL)
            newTasks.append(task)
        }
        
        Promise.combineAll(newTasks)
            .receive(on: .main)
            .sink{ self.tasks.insert(contentsOf: $0, at: 0) }
    }
}

final private class GifConverterView: Page {
    let fpsField = NumberField(autoWidth: ())
    let widthField = NumberField(autoWidth: ())
    let removeFileSwitch = NSSwitch()
    
    let listView = GifConvertListView()
    let dropPublisher = PassthroughSubject<[URL], Never>()
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard.canReadTypes([.fileURL]) { return .copy } else { return .none }
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty else { return false }
        dropPublisher.send(urls)
        return true
    }
    
    override func layout() {
        listView.snp.remakeConstraints{ make in
            make.height.equalTo(max(200, self.frame.height - 330))
        }
        super.layout()
    }
    
    override func onAwake() {
        self.registerForDraggedTypes([.fileURL])
        
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.spacing, title: "Width".localized(), message: "The width of the Gif file (height will be determined)".localized(), control: widthField),
            Area(icon: R.Image.paramators, title: "FPS".localized(), message: "FPS of the Gif file to be exported".localized(), control: fpsField),
            Area(icon: R.Image.paramators, title: "Remove source file".localized(), message: "Whether to delete the source file after exporting a Gif".localized(), control: removeFileSwitch)
        ]))
        
        self.addSection(Section(title: "Images".localized(), items: [
            listView
        ]))
    }
}

final private class GifConvertListView: NSLoadView, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    let scrollView = NSScrollView()
    let listView = EmptyImageTableView.list() => { $0.setFileDropEmptyView() }
    let removePublisher = PassthroughSubject<IndexSet, Never>()
    var convertTasks = [GifConvertTask]() { didSet { listView.reloadData() } }
    
    override func updateLayer() {
        self.layer?.backgroundColor = R.Color.controlBackgroundColor.cgColor
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .space: showQuickLook()
        case .delete: removePublisher.send(listView.selectedRowIndexes)
        default: super.keyDown(with: event)
        }
    }
    
    private func showQuickLook() {
        guard let panel = QLPreviewPanel.shared() else { return }
        panel.dataSource = self
        panel.delegate = self
        panel.makeKeyAndOrderFront(nil)
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        self.addSubview(scrollView)
        self.scrollView.drawsBackground = false
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.scrollView.documentView = listView
        self.listView.delegate = self
        self.listView.dataSource = self
        self.listView.allowsMultipleSelection = true
        
        let menu = NSMenu()
        menu.addItem(title: "Open in Finder".localized()) { [self] in
            guard let task = convertTasks.at(listView.clickedRow) else { return }
            NSWorkspace.shared.activateFileViewerSelecting([task.destinationURL])
        }
        menu.addItem(title: "Delete".localized()) { [self] in
            if listView.clickedRow >= 0 { removePublisher.send(.init(integer: listView.clickedRow)) }
        }
        menu.addItem(title: "Quick Look".localized()) { [self] in
            self.showQuickLook()
        }
        
        self.listView.menu = menu
    }
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        self.listView.selectedRowIndexes.count
    }
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem {
        let index = self.listView.selectedRowIndexes.map{ $0 }[index]
        return convertTasks[index].destinationURL as QLPreviewItem
    }
    func previewPanel(_ panel: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        guard let index = convertTasks.firstIndex(where: { item.isEqual($0.destinationURL) }) else { return .zero }
        
        return listView.convertToScreen(listView.rect(ofRow: index))
    }
}

extension GifConvertListView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int { convertTasks.count }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 64 }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = GifConvertTaskCell()
        let task = convertTasks[row]
        
        cell.titleLabel.stringValue = task.title
        cell.infoLabel.stringValue = "Starting..."
        cell.thumbnailImageView.image = task.thumbnail
        
        task.fftask
            .receive(on: .main)
            .sink{ task in
                task.$progress
                    .receive(on: DispatchQueue.main, options: nil)
                    .filter{ $0 != 0 }
                    .sink{[unowned cell] in
                        cell.progressView.doubleValue = $0
                        cell.infoLabel.stringValue = "\(Int($0 * 100))%"
                    }
                    .store(in: &cell.objectBag)
                
                task.complete
                    .receive(on: .main)
                    .sink({
                        cell.infoLabel.stringValue = "Complete"
                    }, { error in
                        cell.infoLabel.textColor = .systemRed
                        cell.infoLabel.stringValue = "Convert Failed \(error)"
                    })
            }
        
        return cell
    }
}

final private class GifConvertTaskCell: NSLoadView {
    
    static let thumbnailSize: CGSize = [50, 50]
    static let thumbnailImageSize: CGSize = thumbnailSize * (NSScreen.main?.backingScaleFactor ?? 1)
    
    let thumbnailImageView = NSImageView()
    let progressView = NSProgressIndicator()
    let titleLabel = NSTextField(labelWithString: "Title")
    let infoLabel = NSTextField(labelWithString: "Title")
    
    private let stackView = NSStackView()
    private let titleStackView = NSStackView()
    
    override func onAwake() {
        self.addSubview(stackView)
        self.stackView.edgeInsets = .init(x: 16, y: 8)
        self.stackView.distribution = .fillProportionally
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        
        self.stackView.addArrangedSubview(thumbnailImageView)
        self.thumbnailImageView.snp.makeConstraints{ make in
            make.size.equalTo(GifConvertTaskCell.thumbnailSize)
        }
        self.stackView.addArrangedSubview(titleStackView)
        
        self.titleStackView.spacing = 0
        self.titleStackView.orientation = .vertical
        self.titleStackView.alignment = .left
        
        self.titleStackView.addArrangedSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
        
        self.titleStackView.addArrangedSubview(progressView)
        self.progressView.isIndeterminate = false
        self.progressView.minValue = 0
        self.progressView.maxValue = 1
        self.progressView.usesThreadedAnimation = false
        
        self.titleStackView.addArrangedSubview(infoLabel)
        self.infoLabel.font = .systemFont(ofSize: R.Size.controlFontSize)
    }
}

extension NSView {
    public func convertToScreen(_ rect: CGRect) -> CGRect {
        let windowRect = self.convert(rect, to: nil)
        guard let window = self.window else { return windowRect }
        return window.convertToScreen(windowRect)
    }
}
