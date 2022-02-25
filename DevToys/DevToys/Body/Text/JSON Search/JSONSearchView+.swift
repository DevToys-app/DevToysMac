//
//  JSONSearchView.swift
//  DevToys
//
//  Created by yuki on 2022/02/25.
//

import CoreUtil

final class JSONSearchViewController: NSViewController {
    private let cell = JSONSearchView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        
    }
}

enum JSONSearchType: String, TextItem {
    case nomral = "Normal Search"
    case regex = "Regex Search"
    case jsonPath = "JSONPath Search"
    
    var title: String { rawValue }
}

final private class JSONSearchView: Page {
    
    let searchTypePicker = EnumPopupButton<JSONSearchType>()
    
    override func onAwake() {
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.search, title: "Search Type", control: searchTypePicker)
        ]))
    }
}
