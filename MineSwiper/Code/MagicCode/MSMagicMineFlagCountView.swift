//
//  MSMagicMineFlagCountView.swift
//  MineSwiper
//
//  Created by ym on 2017/6/22.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift

class MSMagicMineFlagCountView: NSView {
    
    var imageView1: NSImageView = NSImageView()
    var imageView2: NSImageView = NSImageView()
    var imageView3: NSImageView = NSImageView()

    var bkImageView: NSImageView = NSImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(bkImageView)
        
        addSubview(imageView1)
        addSubview(imageView2)
        addSubview(imageView3)
    }
    
    override func layout() {
        super.layout()
        bkImageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        imageView1.frame = CGRect(x: 5, y: 3, width: 13, height: 23)
        imageView2.frame = CGRect(x: 21, y: 3, width: 13, height: 23)
        imageView3.frame = CGRect(x: 37, y: 3, width: 13, height: 23)
    }
    
    var flagCount: Int = 0 {
        didSet {
            let baiBit: Int = flagCount / 100
            imageView1.image = NSImage(named: NSImage.Name("gnumber_\(baiBit)"))
            
            let tenBit: Int = (flagCount % 100) / 10
            imageView2.image = NSImage(named: NSImage.Name("gnumber_\(tenBit)"))
            
            let geBit: Int = (flagCount % 100) % 10
            imageView3.image = NSImage(named: NSImage.Name("gnumber_\(geBit)"))
        }
    }
}

extension Reactive where Base: MSMagicMineFlagCountView {
    var flags: Binder<Int> {
        return Binder(base) { flagView, flags in
            flagView.flagCount = flags
        }
    }
}
