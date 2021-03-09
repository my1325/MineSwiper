//
//  MSMagicView.swift
//  MineSwiper
//
//  Created by ym on 2017/6/15.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa
import SnapKit
import RxCocoa
import RxSwift

internal final class MSMagicView: NSView, NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {
    
    var items: [MineViewItemCompatiable] = []
    
    internal lazy var collectionView: NSCollectionView = {
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        $0.delegate = self
        $0.dataSource = self
        $0.collectionViewLayout = layout
        $0.isEnableMouseGestureRecognize = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(MSMagicItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MSMagicItem"))
        addSubview($0)
        $0.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return $0
    }(NSCollectionView())
    
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        collectionView.rx.mouseDown.map({ [unowned self] in ($0, self.items[$0.item]) }).asObservable().subscribe(onNext: { [weak self] in
//            guard let wself = self else { return }
//            if case .cover = $0.1.state, !$0.1.flaged, let viewItem = wself.collectionView.item(at: $0.0) as? MSMagicItem {
//                viewItem.magicImageView?.image = NSImage(named: "tile_down")
//            }
//        }).disposed(by: disposeBag)
    }
    
    //MARK:- NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 30, height: 30)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let magicItem: MSMagicItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MSMagicItem"), for: indexPath) as! MSMagicItem
        magicItem.reloadItemWithMineViewItem(items[indexPath.item])
        return magicItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
