//
//  MSMagicItem.swift
//  MineSwiper
//
//  Created by ym on 2017/6/15.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa
let MSMagicFlagCountDidChangedNotification = "MSMagicFlagCountDidChangedNotification"
class MSMagicItem: NSCollectionViewItem, MSMagicGestureRecognizerDelegate {
    
    @IBOutlet weak var magicImageView: NSImageView?
    
    var touchItemHandler: ((IndexPath) -> Void)?
    
    var isGameOver: Bool = false
    
    weak var itemModel: MSMagicModel.MSMagicItemModel?
    
    var magicRecognizer: MSMagicGestureRecognizer = MSMagicGestureRecognizer(target: self, action: #selector(handleMagicGesutreRecognizer(gestureRecognizer:)))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        magicRecognizer.magicDelegate = self
        view.addGestureRecognizer(magicRecognizer)
    }
    
    @objc func handleMagicGesutreRecognizer(gestureRecognizer: MSMagicGestureRecognizer) {}
    
    @objc func handleGameOverNotification(_ notifiction: Notification) {
        isGameOver = true
        
        if itemModel?.magicItem.isMine == true && itemModel?.magicItem.itemState != .flag  {
            magicImageView?.image = notifiction.userInfo?["indexPath"] as? IndexPath != itemModel?.indexPath ? NSImage(named: NSImage.Name("tile_b2")) : itemModel?.unCoverImage
        }
        if itemModel?.magicItem.isMine == false && itemModel?.magicItem.itemState == .flag {
            magicImageView?.image = NSImage(named: NSImage.Name("tile_b3"))
        }
    }
    
    @objc func handleGameReloadNotification(_ notifaction: Notification) {
        isGameOver = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NotificationCenter.default.removeObserver(self)
    }
    
    func prepareForDisplay(model: MSMagicModel.MSMagicItemModel) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameOverNotification(_:)), name: NSNotification.Name(MSMagicGameOverNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameReloadNotification(_:)), name: NSNotification.Name(MSMagicGameReloadNotification), object: nil)

        itemModel = model
        model.imageChangeHandler = { [weak self] (image) in
            self?.magicImageView?.image = image
        }
        
        if model.magicItem.itemState == .unCover {
            magicImageView?.image = model.unCoverImage
        }
        else if model.magicItem.itemState == .cover {
            magicImageView?.image = NSImage(named: NSImage.Name("tile_mask"))
        }
        else {
            magicImageView?.image = NSImage(named: NSImage.Name("tile_d"))
        }
    }
    //右键
    func magicGestureRecognizerRightMouseUp() {
        
        if isGameOver {
            return
        }
        
        if itemModel?.magicItem.itemState == .cover {
            itemModel?.magicItem.itemState = .flag
            magicImageView?.image = NSImage(named: NSImage.Name("tile_d"))
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MSMagicFlagCountDidChangedNotification), object: nil, userInfo: nil)
        }
        else if itemModel?.magicItem.itemState == .flag {
            itemModel?.magicItem.itemState = .cover
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MSMagicFlagCountDidChangedNotification), object: nil, userInfo: nil)
            magicImageView?.image = NSImage(named: NSImage.Name("tile_mask"))
        }
    }
    //左键up
    func magicGestureRecognizerMouseUp() {
        guard let model = itemModel, let handler = touchItemHandler else {
            return
        }
        
        if isGameOver {
            return
        }
        
        if model.magicItem.itemState == .cover {
            handler(model.indexPath!)
        }
        if model.magicItem.isMine == true {
            magicImageView?.image = NSImage(named: NSImage.Name("tile_b"))
        }
    }
    //左键down
    func magicGestureRecognizerMouseDown() {
        
        if isGameOver {
            return
        }
        
        if itemModel?.magicItem.itemState == .cover {
            magicImageView?.image = NSImage(named: NSImage.Name("tile_down"))
        }
    }
}
