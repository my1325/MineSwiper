//
//  MSMagicMap.swift
//  MineSwiper
//
//  Created by ym on 2017/6/12.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa

enum MSMagicType: Int {
    case small = 0
    case middle = 1
    case big = 2
    
    func magic() -> (mines: Int, widthCount: Int, heightCount: Int) {
        
        if self == .small {
            return (10, 9, 9)
        }
        else if self == .middle {
            return (40, 16, 16)
        }
        else {
            return (99, 30, 16)
        }
    }
    
    var itemWidth: Float {
        return 30
    }
    
    var itemHeight: Float {
        return 30
    }
    
    var windowWidth: Float {
        return Float(magic().widthCount) * itemWidth
    }
    
    var windowHeight: Float {
        return Float(magic().heightCount) * itemHeight
    }
}

enum MSMagicTouchType: Int {
    case check = 0
    case flag = 1
}

enum MSMagicCheckFromDirection: String {
    case left = "LEFT"
    case right = "RIGHT"
    case top = "TOP"
    case bottom = "BOTTOM"
    case leftTop = "LEFTTOP"
    case leftBottom = "LEFTBOTTOM"
    case rightTop = "RIGHTTOP"
    case rightBottom = "RIGHTBOTTOM"
    case `default` = "DEFAULT"
}

class MSMagicMap: NSObject {

    class MSMagicMapItem: NSObject {
        
        enum MSMagicMapItemState: Int {
            case cover = 0
            case unCover = 1
            case flag = 2
        }
        
        var itemStateDidChangeHandler: ((MSMagicMapItemState, MSMagicMapItemState) -> Void)?
        var itemState: MSMagicMapItemState = .cover {
            didSet {
                if let handler = itemStateDidChangeHandler {
                    handler(oldValue, itemState)
                }
            }
        }
        var numOfArountMines: Int = 0
        var mapLocation: NSPoint = NSPoint.zero
        var isMine: Bool = false
        var isChecked: Bool = false
        
        weak var topItem: MSMagicMapItem?
        weak var leftItem: MSMagicMapItem?
        weak var bottomItem: MSMagicMapItem?
        weak var rightItem: MSMagicMapItem?
        weak var leftTopItem: MSMagicMapItem?
        weak var rightTopItem: MSMagicMapItem?
        weak var leftBottomItem: MSMagicMapItem?
        weak var rightBottomItem: MSMagicMapItem?
    }
    
    var flagCount: Int = 0
    
    var mapItems: Dictionary<String, MSMagicMapItem> = Dictionary()
    
    func startMagic( magicType: MSMagicType = .small)  {
    
        let magic = magicType.magic()
        
        reloadData(mapWidth: magic.widthCount, mapHeight: magic.heightCount, mines: magic.mines)
    }
    
    func magicItem(atLocation location: NSPoint) -> MSMagicMapItem?
    {
        return mapItems[NSStringFromPoint(location)]
    }
    
    func reloadData(mapWidth: Int, mapHeight: Int, mines: Int) {
        
        flagCount = mines
        
        var mineSet = Set<String>()
        
        let mapCount: UInt32 = UInt32(mapHeight * mapWidth)
        
        var mineIndex = 0
        while mineIndex < mines {
            
            let location = Int(arc4random() % mapCount) //y * width + x
            
            let mineLocation = NSStringFromPoint(NSPoint(x: location % mapWidth, y: location / mapWidth))
            
            if !mineSet.contains(mineLocation) {
                mineSet.insert(mineLocation)
                mineIndex += 1
            }
        }
        
        mapItems.removeAll()
        
        for index in 0 ..< mapWidth * mapHeight {
            
            let widthIndex = index % mapWidth
            let heightIndex = index / mapWidth

            let point = NSPoint(x: widthIndex, y: heightIndex)
            let itemKey = NSStringFromPoint(point)
            
            let item = MSMagicMapItem()
            item.mapLocation = point
            item.itemStateDidChangeHandler = { [weak self] oldState, newState in
                
                if newState == .flag && oldState == .cover {
                    self?.flagCount -= 1
                }
                if newState == .cover && oldState == .flag {
                    self?.flagCount += 1
                }
            }
           
            if mineSet.contains(itemKey) {
                item.isMine = true
            }
            else {
                item.isMine = false
            }
            //左上
            let letTopItem = mapItems[NSStringFromPoint(NSPoint(x: widthIndex - 1, y: heightIndex - 1))]
            item.leftTopItem = letTopItem
            item.numOfArountMines += letTopItem?.isMine == true ? 1 : 0
            //右下
            letTopItem?.rightBottomItem = item
            letTopItem?.numOfArountMines += item.isMine ? 1 : 0
            //上
            let topItem = mapItems[NSStringFromPoint(NSPoint(x: widthIndex, y: heightIndex - 1))]
            item.topItem = topItem
            item.numOfArountMines += topItem?.isMine == true ? 1 : 0
            //下
            topItem?.bottomItem = item
            topItem?.numOfArountMines += item.isMine ? 1 : 0
            //右上
            let rightTopItem = mapItems[NSStringFromPoint(NSPoint(x: widthIndex + 1, y: heightIndex - 1))]
            item.rightTopItem = rightTopItem
            item.numOfArountMines += rightTopItem?.isMine == true ? 1 : 0
            //左下
            rightTopItem?.leftBottomItem = item
            rightTopItem?.numOfArountMines += item.isMine ? 1 : 0
            //左
            let leftItem = mapItems[NSStringFromPoint(NSPoint(x: widthIndex - 1, y: heightIndex))]
            item.leftItem = leftItem
            item.numOfArountMines += leftItem?.isMine == true ? 1 : 0
            //右
            leftItem?.rightItem = item
            leftItem?.numOfArountMines += item.isMine ? 1 : 0
            
            mapItems[itemKey] = item
        }
    }
    
    private func checkAround(location: NSPoint, fromDirection: MSMagicCheckFromDirection = .default, unCovers: inout Array<String>) {
        let locationKey = NSStringFromPoint(location)
        
        if let item = mapItems[locationKey] {
            
            if item.isChecked || item.isMine {
                return
            }
            
            item.isChecked = true
            
            if item.numOfArountMines != 0 {
                unCovers.append(locationKey)
                item.itemState = .unCover
                return
            }
            if item.leftItem != nil && fromDirection != .left {
                
                unCovers.append(locationKey)
                item.itemState = .unCover
                checkAround(location: (item.leftItem?.mapLocation)!, fromDirection: .right, unCovers: &unCovers)
            }
            if item.topItem != nil && fromDirection != .top {
                
                unCovers.append(locationKey)
                item.itemState = .unCover
                checkAround(location: (item.topItem?.mapLocation)!, fromDirection: .bottom, unCovers: &unCovers)
            }
            if item.rightItem != nil && fromDirection != .right {
                
                unCovers.append(locationKey)
                item.itemState = .unCover
                checkAround(location: (item.rightItem?.mapLocation)!, fromDirection: .left, unCovers: &unCovers)
            }
            if item.bottomItem != nil && fromDirection != .bottom {
                
                unCovers.append(locationKey)
                item.itemState = .unCover
                checkAround(location: (item.bottomItem?.mapLocation)!, fromDirection: .top, unCovers: &unCovers)
            }
            if item.leftTopItem != nil && fromDirection != .leftTop {
                
                unCovers.append(locationKey)
                item.itemState = .unCover
                checkAround(location: (item.leftTopItem?.mapLocation)!, fromDirection: .rightBottom, unCovers: &unCovers)
            }
            if item.rightTopItem != nil && fromDirection != .rightTop {
                
                unCovers.append(locationKey)
                item.itemState = .unCover
                checkAround(location: (item.rightTopItem?.mapLocation)!, fromDirection: .leftBottom, unCovers: &unCovers)
            }
            if item.leftBottomItem != nil && fromDirection != .leftBottom {
                
                unCovers.append(locationKey)
                item.itemState = .unCover
                checkAround(location: (item.leftBottomItem?.mapLocation)!, fromDirection: .rightTop, unCovers: &unCovers)
            }
            if item.rightBottomItem != nil && fromDirection != .rightBottom {
                
                unCovers.append(locationKey)
                item.itemState = .unCover
                checkAround(location: (item.rightBottomItem?.mapLocation)!, fromDirection: .leftTop, unCovers: &unCovers)
            }
        }
    }
    
    /// 点击地图时间
    ///
    /// - Parameters:
    ///   - location: 点击的位置
    ///   - type: 点击的类型
    /// - Returns: flag: 标识符（-1, 游戏结束，1，游戏继续）， locations: 需要刷新的位置数组
    func touchMap(location: NSPoint, type: MSMagicTouchType = .check) -> (flag: Int, locations: Array<String>) {
        
        let locationKey = NSStringFromPoint(location)
        
        var locations: Array<String> = Array()
        var flag: Int = 1
        
        if let item = mapItems[locationKey] {

            switch item.itemState {
            case .cover:
                
                if type == .check {
                    item.itemState = .unCover
                    if item.isMine {
                        flag = -1
                    }
                    else {
                        checkAround(location: location, unCovers: &locations)
                    }
                }
                if type == .flag {
                    item.itemState = .flag
                }
            case .flag:
                
                if type == .flag {
                    item.itemState = .cover
                }
                
            case .unCover: break
            }
        }
        
        return (flag, locations)
    }
}
