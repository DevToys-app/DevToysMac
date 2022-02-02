//
//  PDFGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/02.
//

import CoreUtil

final class PDFGeneratorViewController: ToolPageViewController {
    private let cell = PDFGeneratorView()
    
    @Observable var images = [ImageItem]()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$images
            .sink{[unowned self] in cell.imageListView.imageItems = $0 }.store(in: &objectBag)
        
        self.cell.dragPublisher
            .sink{[unowned self] in readURLs($0) }.store(in: &objectBag)
        self.cell.generateButton.actionPublisher
            .sink{[unowned self] in makePDF(from: self.images.map{ $0.image }) }.store(in: &objectBag)
        self.cell.imageListView.removePublisher
            .sink{[unowned self] in $0.reversed().forEach{ self.images.remove(at: $0) } }.store(in: &objectBag)
        self.cell.imageListView.movePublisher
            .sink{[unowned self] in self.images.move(fromIndex: $0.from, toIndex: $0.to) }.store(in: &objectBag)
    }
    
    private func readURLs(_ pasteboard: NSPasteboard) {
        var newImageItems = [ImageItem]()
        
        guard let items = pasteboard.pasteboardItems else { return }
        
        if items.count == 1 {
            guard let image = NSImage(pasteboard: pasteboard) else { return }
            let imageName = (pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL])?.first?.lastPathComponent ?? "Image"
            newImageItems =  [ImageItem(title: imageName, image: image)]
        } else {
            guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else { return }
            let images = urls.compactMap{ url in
                NSImage(contentsOf: url).map{ ImageItem(title: url.lastPathComponent, image: $0) }
            }
            newImageItems = images
        }
        images.append(contentsOf: newImageItems)
        
        guard let last = cell.imageListView.documentView?.frame.size.height else { return }
        
        cell.imageListView.contentView.animator().scroll(to: [0, last - cell.imageListView.frame.height])
    }
    
    private func makePDF(from images: [NSImage]) {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["pdf"]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        
        let promise = Promise<Void, Never>.async { resolve, _ in
            let pdfData = NSMutableData()
            
            var mediaSize = CGRect(x: 0, y: 0, width: 2000, height: 1000)
            let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
            let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaSize, nil)!
            
            for image in images {
                var rect = CGRect(size: image.size)
                pdfContext.beginPage(mediaBox: &rect)
                pdfContext.draw(image.cgImage!, in: rect)
                pdfContext.endPage()
            }
            pdfContext.closePDF()
            
            FileManager.default.createFile(atPath: url.path, contents: pdfData as Data, attributes: nil)
            
            resolve(())
        }
        .receive(on: .main)
        
        let toast = Toast(message: "Generating PDF...")
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.startAnimation(nil)
        indicator.snp.makeConstraints{ make in
            make.size.equalTo(16)
        }
        toast.addAttributeView(indicator, position: .right)
        toast.show(with: { promise.sink($0) })
        
        promise.sink{
            Toast.show(message: "PDF Exported!")
        }
    }
}
 
private enum ScaleMode: String, TextItem {
    case scalePage = "Scale Page"
    case scaleToFit = "Scale to Fit"
    case scaleToFill = "Scale to Fill"
    
    var title: String { rawValue }
}

final private class PDFGeneratorView: ToolPage {
    let imageListView = ImageListView()
    let generateButton = Button(title: "Generate PDF")
    let scaleModePicker = EnumPopupButton<ScaleMode>()
    let dragPublisher = PassthroughSubject<NSPasteboard, Never>()
    
    override func layout() {
        super.layout()
        self.imageListView.snp.remakeConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 100))
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard.canReadTypes([.URL, .fileURL, .fileContents]) { return .copy } else { return .none }
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty else { return false }
        self.dragPublisher.send(sender.draggingPasteboard)
        return true
    }
    
    override func onAwake() {
        self.title = "PDF Generator"
        self.registerForDraggedTypes([.URL, .fileURL, .fileContents])
        
        self.addSection2(
            ControlSection(title: "Images", items: [imageListView]),
            ControlSection(title: "Configuration", items: [
                ControlArea(icon: R.Image.paramators, title: "Scale Mode", control: scaleModePicker),
                generateButton,
            ]) => {
                $0.stackView.alignment = .width
            }
        ) => {
            $0.alignment = .top
        }
    }
}

struct ImageItem {
    let title: String
    let image: NSImage
}

final private class ImageListView: NSLoadScrollView {
    let listView = NSTableView.list()
    var imageItems = [ImageItem]() { didSet { listView.reloadData() } }
    var removePublisher = PassthroughSubject<[Int], Never>()
    var movePublisher = PassthroughSubject<(from: Int, to: Int), Never>()
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .delete: self.removePublisher.send(listView.selectedRowIndexes.map{ $0 })
        default: super.keyDown(with: event)
        }
    }
    
    override func onAwake() {
        self.drawsBackground = true
        self.backgroundColor = .quaternaryLabelColor
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        self.documentView = listView
//        self.listView.allowsMultipleSelection = true
        self.listView.delegate = self
        self.listView.dataSource = self
        self.listView.registerForDraggedTypes([.imageItem])
    }
}

extension ImageListView: NSTableViewDelegate, NSTableViewDataSource {
    
    private class Cell: NSLoadStackView {
        let imageView = NSImageView()
        let titleLabel = NSTextField(labelWithString: "Title")
        let pageLabel = NSTextField(labelWithString: "Page 1")
        
        override func updateLayer() {
            imageView.layer?.backgroundColor = NSColor.tertiaryLabelColor.withAlphaComponent(0.05).cgColor
        }
        
        override func onAwake() {
            self.imageView.wantsLayer = true
            self.imageView.layer?.cornerRadius = R.Size.corner
            self.spacing = 16
            self.edgeInsets = .init(x: 16, y: 4)
            self.addArrangedSubview(imageView)
            self.imageView.snp.makeConstraints{ make in
                make.width.equalTo(100)
                make.height.equalTo(64)
            }
            
            self.addArrangedSubview(NSStackView() => {
                $0.orientation = .vertical
                $0.alignment = .left
                $0.addArrangedSubview(titleLabel)
                $0.addArrangedSubview(pageLabel)
            })
            self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
            self.titleLabel.lineBreakMode = .byTruncatingTail
            
            self.pageLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
            self.pageLabel.textColor = .secondaryLabelColor
            self.pageLabel.lineBreakMode = .byTruncatingTail
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int { self.imageItems.count }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 80 }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = Cell()
        let imageItem = imageItems[row]
        cell.titleLabel.stringValue = imageItem.title
        cell.imageView.image = imageItem.image
        cell.pageLabel.stringValue = "Page \(row + 1)"
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        if edge == .trailing {
            return [.init(style: .destructive, title: "Delete", handler: { _, row in
                self.removePublisher.send([row])
            })]
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        NSPasteboardItem() => {
            $0.setPropertyList(row, forType: .imageItem)
        }
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above { return .move }
        return .none
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard dropOperation == .above else { return false }
        guard let fromRow = info.draggingPasteboard.propertyList(forType: .imageItem) as? Int else { return false }
        
        movePublisher.send((fromRow, row))
        
        return true
    }
}

extension NSPasteboard.PasteboardType {
    static let imageItem = NSPasteboard.PasteboardType("com.devtoys.imageitem")
}
