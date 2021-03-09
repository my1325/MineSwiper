//
//  AppDelegate.swift
//  MineSwiper
//
//  Created by ym on 2017/6/12.
//  Copyright © 2017年 MZ. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    var mainWindowController: MSMainWC?
    
    @IBOutlet weak var primaryMenuItem: NSMenuItem?
    @IBOutlet weak var intermediateMenuItem: NSMenuItem?
    @IBOutlet weak var highMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        mainWindowController = MSMainWC()
        mainWindowController!.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func touchPrimaryMenuItem(_ item: NSMenuItem) {
        item.state = NSControl.StateValue(rawValue: 1)
        intermediateMenuItem?.state = NSControl.StateValue(rawValue: 0)
        highMenuItem?.state = NSControl.StateValue(rawValue: 0)
        
        mainWindowController?.reload(.default)
    }
    @IBAction func touchIntermediateMenuItem(_ item: NSMenuItem) {
        item.state = NSControl.StateValue(rawValue: 1)
        primaryMenuItem?.state = NSControl.StateValue(rawValue: 0)
        highMenuItem?.state = NSControl.StateValue(rawValue: 0)
        
        mainWindowController?.reload(.middle)
    }
    @IBAction func touchHighMenuItem(_ item: NSMenuItem) {
        item.state = NSControl.StateValue(rawValue: 1)
        primaryMenuItem?.state = NSControl.StateValue(rawValue: 0)
        intermediateMenuItem?.state = NSControl.StateValue(rawValue: 0)
        
        mainWindowController?.reload(.big)
    }
}

