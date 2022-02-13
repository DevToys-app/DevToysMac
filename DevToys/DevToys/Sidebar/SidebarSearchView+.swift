//
//  SidebarSearchView+.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class SidebarSearchViewController: NSViewController {
    private let searchView = SidebarSearchView()
    
    override func loadView() { self.view = searchView }
        
    override func chainObjectDidLoad() {
        self.appModel.$searchQuery
            .sink{[unowned self] in self.searchView.searchView.stringValue = $0 }.store(in: &objectBag)
        self.searchView.searchView.changeStringPublisher
            .sink{[unowned self] in self.appModel.searchQuery = $0 }.store(in: &objectBag)
    }
}

final private class SidebarSearchView: NSLoadView {
    let searchView = NSSearchField()
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(32)
        }
        self.addSubview(searchView)
        self.searchView.placeholderString = "Type to search for tools..."
        self.searchView.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.left.equalToSuperview().inset(16)
        }
    }
}
