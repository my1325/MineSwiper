//
//  MSMagicItem.swift
//  MineSwiper
//
//  Created by ym on 2017/6/15.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa

enum MineViewItemState {
    case cover
    case uncover
}

protocol MineViewItemCompatiable {
    var icon: NSImage? { get }
    var flaged: Bool { get }
    var state: MineViewItemState { get }
}

internal final class MSMagicItem: NSCollectionViewItem {
    
    @IBOutlet weak var magicImageView: NSImageView?
    
    func reloadItemWithMineViewItem(_ mineItem: MineViewItemCompatiable) {
        magicImageView?.image = mineItem.icon
    }
}
