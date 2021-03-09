//
//  MSMagicGestureRecognizer.swift
//  MineSwiper
//
//  Created by ym on 2017/6/15.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa

protocol MSMagicGestureRecognizerDelegate: NSObjectProtocol {
    
    func magicGestureRecognizerMouseDown(_ gestureRecognizer: MSMagicGestureRecognizer)
    
    func magicGestureRecognizerMouseUp(_ gestureRecognizer: MSMagicGestureRecognizer)
    
    func magicGestureRecognizerRightMouseUp(_ gestureRecognizer: MSMagicGestureRecognizer)
}

class MSMagicGestureRecognizer: NSGestureRecognizer {
    
    weak var magicDelegate: MSMagicGestureRecognizerDelegate?
    
    override init(target: (Any)?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        magicDelegate?.magicGestureRecognizerMouseUp(self)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        magicDelegate?.magicGestureRecognizerMouseDown(self)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        magicDelegate?.magicGestureRecognizerRightMouseUp(self)
    }
}
