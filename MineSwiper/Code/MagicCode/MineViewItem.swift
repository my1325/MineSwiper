//
//  MineViewItem.swift
//  MineSwiper
//
//  Created by my on 2021/3/9.
//  Copyright © 2021 MZ. All rights reserved.
//

import Cocoa

struct MineViewItem: MineViewItemCompatiable {
    let mineItem: MineItem
    
    var icon: NSImage? {
        switch mineItem {
        case .covered(.default):
            return NSImage(named: "tile_mask")
        case .covered(.flag):
            return NSImage(named: "tile_d")
        case .uncovered(.mine):
            return NSImage(named: "tile_b2")
        case .uncovered(.currentMine):
            return NSImage(named: "tile_b")
        case let .uncovered(.number(number)):
            return NSImage(named: "tile_\(number)")
        case .uncovered(.flagWrong):
            return NSImage(named: "tile_b3")
        }
    }
    
    var state: MineViewItemState {
        switch mineItem {
        case .covered:
            return .cover
        case .uncovered:
            return .uncover
        }
    }
    
    var flaged: Bool {
        switch mineItem {
        case .covered(.flag):
            return true
        default:
            return false
        }
    }
}
