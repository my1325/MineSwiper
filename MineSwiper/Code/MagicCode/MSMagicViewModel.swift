//
//  MSMagicViewModel.swift
//  MineSwiper
//
//  Created by ym on 2017/6/15.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa

class MSMagicModel: NSObject {
    
    class MSMagicItemModel: NSObject {
        
        var imageChangeHandler: ((NSImage) -> Void)?
        
        var indexPath: IndexPath?
        
        var unCoverImage: NSImage?
        
        var magicItem: MSMagicMap.MSMagicMapItem = MSMagicMap.MSMagicMapItem() {
            didSet {
                if magicItem.isMine {
                    unCoverImage = NSImage(named: NSImage.Name("tile_b"))
                }
                else if magicItem.numOfArountMines == 0 {
                    unCoverImage = NSImage(named: NSImage.Name("tile_base"))
                }
                else {
                    unCoverImage = NSImage(named: NSImage.Name("tile_\(magicItem.numOfArountMines)"))
                }
            }
        }
        
        func magicItemStateChanged() {
            if let handler = imageChangeHandler {
                handler(unCoverImage!)
            }
        }
    }
    
    var flagCount: Int {
        get {
            return magicMap.flagCount
        }
    }
    
    var magicItemModels: Dictionary<String, MSMagicItemModel> = Dictionary()
    
    var magicMap: MSMagicMap = MSMagicMap()
    
    var magicType: MSMagicType = .small {
        didSet {
            magicItemModels.removeAll()
            magicMap.startMagic(magicType: magicType)
        }
    }
    var magicItems: Int {
        
        return magicType.magic().heightCount * magicType.magic().widthCount;
    }
    var magicItemWidth: Float {
        
        return magicType.itemWidth;
    }
    var magicItemHeight: Float {
       
        return magicType.itemHeight
    }
    
    func magicItemModel(atIndexPath: IndexPath) -> MSMagicItemModel {
        
        let point = NSPoint(x: atIndexPath.item % magicType.magic().widthCount, y: atIndexPath.item / magicType.magic().widthCount)
        let key = NSStringFromPoint(point)
        
        if let itemModel = magicItemModels[key] {
            return itemModel
        }
        
        let model: MSMagicItemModel = MSMagicItemModel()
        model.indexPath = atIndexPath
        model.magicItem = magicMap.magicItem(atLocation: point)!
        
        magicItemModels[key] = model
        
        return model
    }
    
    func magicItemTouched(atIndexPath: IndexPath) -> Bool {
        let point = NSPoint(x: atIndexPath.item % magicType.magic().widthCount, y: atIndexPath.item / magicType.magic().widthCount)
        let touchResult = magicMap.touchMap(location: point, type: .check)
        
        if touchResult.flag == -1 {
            return true
        }
    
        for key in touchResult.locations {
            let itemModel = magicItemModels[key]
            itemModel?.magicItemStateChanged()
        }
        return false
    }
}
