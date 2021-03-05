//
//  MSMagicView.swift
//  MineSwiper
//
//  Created by ym on 2017/6/15.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa

let MSMagicGameStartNotification: String = "MSMagicGameStartNotification"
let MSMagicGameOverNotification: String = "MSMagicGameOverNotification"

class MSMagicView: NSView, NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {
    
    var isFirstTouch: Bool = true
    
    var magicType: MSMagicType = .small {
        didSet {
            magicModel.magicType = magicType
        }
    }
    
    let magicModel: MSMagicModel = MSMagicModel()
    
    private lazy var magicCollectionView: NSCollectionView = {
        
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = NSCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MSMagicItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MSMagicItem"))
                
        self.addSubview(collectionView)
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        return collectionView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func touchItem(atIndexPath indexPath: IndexPath) {
        
        let isGameOver = magicModel.magicItemTouched(atIndexPath: indexPath)
        //游戏结束
        if isGameOver {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MSMagicGameOverNotification), object: nil, userInfo: ["indexPath": indexPath])
            isFirstTouch = true
        }
    }
    
    func reloadData() {
        magicCollectionView.reloadData()
    }
    
    //MARK:- NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return magicModel.magicItems
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize
    {
        return NSSize(width: CGFloat(magicModel.magicItemWidth), height: CGFloat(magicModel.magicItemHeight))
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    {
        let magicItem: MSMagicItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MSMagicItem"), for: indexPath) as! MSMagicItem
        magicItem.prepareForDisplay(model: magicModel.magicItemModel(atIndexPath: indexPath))
        magicItem.touchItemHandler = { [weak self] IP in
            if self?.isFirstTouch == true {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MSMagicGameStartNotification), object: nil, userInfo: nil)
                self?.isFirstTouch = false
            }
            self?.touchItem(atIndexPath: IP)
        }
        return magicItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
}
