//
//  SidebarSearchView+.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class SidebarSearchCellController: NSViewController {
    private let cell = SidebarSearchCell()
    
    override func loadView() { self.view = cell }
        
    override func chainObjectDidLoad() {
        self.appModel.$searchQuery
            .sink{[unowned self] in self.cell.searchView.stringValue = $0 }.store(in: &objectBag)
        self.cell.searchView.changeStringPublisher
            .sink{[unowned self] in self.appModel.searchQuery = $0 }.store(in: &objectBag)
    }
}

final class SidebarSearchCell: NSLoadView {
    
    static let height: CGFloat = 48
    
    let searchView = SidebarSearchField()
    
    override func onAwake() {
        self.addSubview(searchView)
        self.searchView.snp.makeConstraints{ make in
            make.height.equalTo(29)
            make.centerY.equalToSuperview()
            make.right.left.equalToSuperview()
        }
    }
}

final class SidebarSearchField: NSSearchField {
    override var focusRingMaskBounds: NSRect { bounds }
    
    override func drawFocusRingMask() {
        NSBezierPath(roundedRect: bounds.slimmed(by: 1), xRadius: 4, yRadius: 4).fill()
    }
}
