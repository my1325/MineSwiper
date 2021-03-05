//
//  MSMagicMineFlagCountView.swift
//  MineSwiper
//
//  Created by ym on 2017/6/22.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa

class MSMagicMineFlagCountView: NSView {
    
    var imageView1: NSImageView = NSImageView()
    var imageView2: NSImageView = NSImageView()
    var imageView3: NSImageView = NSImageView()

    var bkImageView: NSImageView = NSImageView()

    var flagCount: Int = 0 {
        didSet {
            if flagCount >= 0 {
                let baiBit: Int = flagCount / 100
                imageView1.image = NSImage(named: NSImage.Name("gnumber_\(baiBit)"))
                
                let tenBit: Int = (flagCount % 100) / 10
                imageView2.image = NSImage(named: NSImage.Name("gnumber_\(tenBit)"))
                
                let geBit: Int = (flagCount % 100) % 10
                imageView3.image = NSImage(named: NSImage.Name("gnumber_\(geBit)"))
            }
            else if flagCount > -100 {
                
                imageView1.image = flagCount <= -10 ? NSImage(named: NSImage.Name("gnumber_dash")) : NSImage(named: NSImage.Name("gnumber_0"))
                
                let tenBit: Int = (abs(flagCount) % 100) / 10
                imageView2.image = tenBit == 0 ? NSImage(named: NSImage.Name("gnumber_dash")) : NSImage(named: NSImage.Name("gnumber_\(tenBit)"))
                
                let geBit: Int = (abs(flagCount) % 100) % 10
                imageView3.image = NSImage(named: NSImage.Name("gnumber_\(geBit)"))
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
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
    
}
