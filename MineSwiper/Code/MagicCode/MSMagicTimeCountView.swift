//
//  MSMagicTimeCountView.swift
//  MineSwiper
//
//  Created by ym on 2017/6/22.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class MSMagicTimeCountView: NSView {
    
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
        
        timeCount = 0
    }
    
    override func layout() {
        super.layout()
        bkImageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        imageView1.frame = CGRect(x: 5, y: 3, width: 13, height: 23)
        imageView2.frame = CGRect(x: 21, y: 3, width: 13, height: 23)
        imageView3.frame = CGRect(x: 37, y: 3, width: 13, height: 23)
    }
    
    var timeCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                let baiBit: Int = self.timeCount / 100
                self.imageView1.image = NSImage(named: NSImage.Name("gnumber_\(baiBit)"))
                
                let tenBit: Int = (self.timeCount % 100) / 10
                self.imageView2.image = NSImage(named: NSImage.Name("gnumber_\(tenBit)"))
                
                let geBit: Int = (self.timeCount % 100) % 10
                self.imageView3.image = NSImage(named: NSImage.Name("gnumber_\(geBit)"))
            }
        }
    }
}

extension Reactive where Base: MSMagicTimeCountView {
    var timeCount: Binder<Int> {
        return Binder(base) { timeCountView, count in
            timeCountView.timeCount = count
        }
    }
}
