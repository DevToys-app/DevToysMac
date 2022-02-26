//
//  Settings.swift
//  DevToys
//
//  Created by yuki on 2022/02/16.
//

import CoreUtil

final class Settings {
    enum AppearanceType: String {
        case useSystemSettings = "Use system setting"
        case lightMode = "Light mode"
        case darkMode = "Dark mode"
    }
     
    @RestorableState("appearance") var appearanceType: AppearanceType = .useSystemSettings
}
