//
//  SidebarSearchView+.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class SidebarSearchViewController: NSViewController {
    private let searchView = SidebarSearchView()
    
    override func loadView() {
        self.view = searchView
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
