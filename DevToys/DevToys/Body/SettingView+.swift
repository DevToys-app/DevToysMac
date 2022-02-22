//
//  SettingView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/16.
//

import CoreUtil

final class SettingViewController: NSViewController {
    private let cell = SettingView()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        self.appModel.settings.$appearanceType
            .sink{[unowned self] in self.cell.appearancePicker.selectedItem = $0 }.store(in: &objectBag)
        
        self.cell.appearancePicker.itemPublisher
            .sink{[unowned self] in self.appModel.settings.appearanceType = $0 }.store(in: &objectBag)
    }
}

extension Settings.AppearanceType: TextItem {
    static let allCases: [Self] = [.useSystemSettings, .lightMode, .darkMode]
    
    var title: String { rawValue.localized() }
}

final private class SettingView: Page {
    
    let appearancePicker = EnumPopupButton<Settings.AppearanceType>()
    
    override func onAwake() {
        self.addSection(
            Area(icon: R.Image.paramators, title: "App Theme".localized(), message: "Select which app theme to display".localized(), control: appearancePicker)
        )
    }
}
