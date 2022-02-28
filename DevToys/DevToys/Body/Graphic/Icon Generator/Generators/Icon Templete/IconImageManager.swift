//
//  IconImageManager.swift
//  DevToys
//
//  Created by yuki on 2022/02/28.
//

import CoreUtil

final class IconImageManager {
    var templetes = [IconTemplete]()
    private var templeteMap = [String: IconTemplete]()
    
    func templete(for identifier: String) -> IconTemplete? {
        self.templeteMap[identifier]
    }
    func register(_ templete: IconTemplete) {
        self.templetes.append(templete)
        self.templeteMap[templete.identifier] = templete
    }
}

extension IconImageManager {
    static let shared = IconImageManager() => {
        $0.register(OriginalIconTemplete())
        $0.register(FolderFillIconTemplete())
        $0.register(FolderCenterIconTemplete())
        $0.register(FolderCenterEngravedIconTemplete())
        $0.register(BigSurFillIconTemplete())
        $0.register(AndroidIconTemplete())
        $0.register(CircleIconTemplete())
        $0.register(RoundedRectIconTemplete())
    }
}

