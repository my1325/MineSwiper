//
//  MSMainWC.swift
//  MineSwiper
//
//  Created by ym on 2017/6/12.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa
import SnapKit
import RxSwift

extension MineGame.Map {
    
    var itemWidth: CGFloat {
        return 30
    }
    
    var itemHeight: CGFloat {
        return 30
    }
    
    var windowWidth: CGFloat {
        return CGFloat(width) * itemWidth
    }
    
    var windowHeight: CGFloat {
        return CGFloat(height) * itemHeight
    }
}

class MSMainWC: NSWindowController {
    
    @IBOutlet weak var magicView: MSMagicView!
    @IBOutlet weak var magicMineFlagView: MSMagicMineFlagCountView!
    @IBOutlet weak var magicStartView: NSButton!
    @IBOutlet weak var magicTimeCountView: MSMagicTimeCountView!
    
    override var windowNibName: NSNib.Name? { return NSNib.Name("MSMainWC") }
    override var owner: AnyObject? { return self }
    
    let mineGame = MineGame(map: .default)
    
    let disposeBag = DisposeBag()
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        mineGame.rx.flagLocation.map({ [unowned self] _ in self.mineGame.flags }).bind(to: magicMineFlagView.rx.flags).disposed(by: disposeBag)
        mineGame.rx.playingTimeInterval.map({ Int($0) }).bind(to: magicTimeCountView.rx.timeCount).disposed(by: disposeBag)
        mineGame.rx.mineItems.map({ $0.reduce([], { $0 + $1 }).map({ MineViewItem(mineItem: $0) }) }).bind(to: magicView.rx.mineItems).disposed(by: disposeBag)
        
        magicView.rx.didTouchMineItem.map({ $0.item }).bind(to: mineGame.rx.uncoverLocationActions).disposed(by: disposeBag)
        magicView.rx.didRightTouchMineItem.map({ $0.item }).bind(to: mineGame.rx.flagLocationAction).disposed(by: disposeBag)
        
        reload(.default)
    }
    
    func reload(_ map: MineGame.Map) {
        mineGame.map = map
        magicMineFlagView?.flagCount = 0
        
        magicView.updateConstraint(forWidth: map.windowWidth)
        magicView.updateConstraint(forHeight: map.windowHeight)
    }
    
    @IBAction func touchStartButton(_ sender: NSButton) {
        mineGame.start()
    }
}
