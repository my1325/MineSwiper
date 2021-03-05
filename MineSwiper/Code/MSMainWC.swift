//
//  MSMainWC.swift
//  MineSwiper
//
//  Created by ym on 2017/6/12.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa

let MSMagicGameReloadNotification = "MSMagicGameReloadNotification"

class MSMainWC: NSWindowController {
    
    @IBOutlet weak var magicView: MSMagicView?
    @IBOutlet weak var magicMineFlagView: MSMagicMineFlagCountView?
    @IBOutlet weak var magicStartView: NSButton?
    @IBOutlet weak var magicTimeCountView: MSMagicTimeCountView?
    @IBOutlet weak var magicViewHeight: NSLayoutConstraint?
    @IBOutlet weak var magicViewWidth: NSLayoutConstraint?
    
    override var windowNibName: NSNib.Name? { return NSNib.Name("MSMainWC") }
    override var owner: AnyObject? { return self }
    
    var type: MSMagicType = .small
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        NotificationCenter.default.addObserver(self, selector: #selector(handleFlagCountNotification(_:)), name: NSNotification.Name(rawValue: MSMagicFlagCountDidChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameStartNotification(_:)), name: NSNotification.Name(rawValue: MSMagicGameStartNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameOverNotification(_:)), name: NSNotification.Name(rawValue: MSMagicGameOverNotification), object: nil)
        reload(magicType: .small)
    }
    
    @objc func handleGameOverNotification(_ notification: NotificationCenter) {
        magicTimeCountView?.stopTimer()
    }
    
    @objc func handleGameStartNotification(_ notification: Notification) {
        magicTimeCountView?.startTimer()
    }
    
    @objc func handleFlagCountNotification(_ notification: Notification) {
        magicMineFlagView?.flagCount = (magicView?.magicModel.flagCount)!
    }
    
    func reload(magicType: MSMagicType) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MSMagicGameReloadNotification), object: nil, userInfo: nil)
        
        type = magicType
       
        magicView?.magicType = magicType
        magicView?.reloadData()
        magicView?.isFirstTouch = true
        magicTimeCountView?.timeCount = 0
        magicTimeCountView?.stopTimer()
        magicMineFlagView?.flagCount = (magicView?.magicModel.flagCount)!
        
        magicViewWidth?.constant = CGFloat(magicType.windowWidth)
        magicViewHeight?.constant = CGFloat(magicType.windowHeight)
    }
    
    @IBAction func touchStartButton(_ sender: NSButton) {
        reload(magicType: type)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
