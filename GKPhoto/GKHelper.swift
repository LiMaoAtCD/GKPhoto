//
//  GKHelper.swift
//  GKPhoto
//
//  Created by mao li on 2018/10/29.
//  Copyright © 2018 MarcoLi. All rights reserved.
//

import UIKit

class GKHelper: NSObject {
    static let `default` = GKHelper()

    var count: Int = 0
    var identifiers = [String]()
    var maxStorage: Int = 9
    var indexPaths = [IndexPath]()

    private override init() {
        super.init()
    }

    func insert(_ identifier: String, indexPath: IndexPath) {
        if identifiers.count < maxStorage {
            identifiers.append(identifier)
            indexPaths.append(indexPath)
        }
    }

    func delete(_ idenitifer: String) {
        if let index = identifiers.firstIndex(of: idenitifer) {
            identifiers.remove(at: index)
            indexPaths.remove(at: index)
        }
    }

    func getCount() -> Int {
        return identifiers.count
    }

    func isMaxNumber() -> Bool {
        return identifiers.count == maxStorage
    }
}
