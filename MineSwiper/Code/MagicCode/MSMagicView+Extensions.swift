//
//  MSMagicView+Extensions.swift
//  MineSwiper
//
//  Created by my on 2021/3/8.
//  Copyright © 2021 MZ. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: MSMagicView {
    var mineItems: Binder<[MineViewItemCompatiable]> {
        return Binder(base) { magicView, items in
            magicView.items = items
            magicView.collectionView.reloadData()
        }
    }
    
    var didTouchMineItem: Observable<IndexPath> {
        return base.collectionView.rx.mouseDown.asObservable()
    }
    
    var didRightTouchMineItem: Observable<IndexPath> {
        return base.collectionView.rx.rightMouseUp.asObservable()
    }
}
