//
//  ThreadTimer.swift
//  MineSwiper
//
//  Created by my on 2021/3/8.
//  Copyright © 2021 MZ. All rights reserved.
//

import Foundation

internal final class WeakTargetProxy {

    let targetAction: () -> Void
    init(_ action: @escaping () -> Void) {
        self.targetAction = action
    }
    
    @objc func handleTargetEvent() {
        targetAction()
    }
}

internal final class ThreadTimer {
    private(set) var timer: Timer!
    let action: (ThreadTimer) -> Void
    private var  thread: Thread!
    private let timeInterval: TimeInterval
    private let repeats: Bool
    
    private enum State {
        case idle
        case fire
        case suspend
    }
    
    private var state: State = .idle
    
    init(timeInterval: TimeInterval = 1, repeats: Bool = true, action: @escaping (ThreadTimer) -> Void) {
        self.action = action
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.thread = Thread(target: WeakTargetProxy({ [weak self] in
           
            let _timer = Timer(timeInterval: timeInterval, target: WeakTargetProxy({ [weak self] in
                guard let wself = self else { return }
                wself.action(wself)
            }), selector: #selector(WeakTargetProxy.handleTargetEvent), userInfo: nil, repeats: repeats)
         
            if self?.state == .fire {
                _timer.fireDate = Date.distantPast
            }
            self?.timer = _timer
            let runloop = RunLoop.current
            runloop.add(_timer, forMode: .default)
            runloop.run()

        }), selector: #selector(WeakTargetProxy.handleTargetEvent), object: nil)
        
        self.thread.start()
    }
    
    func fire() {
        if let _timer = timer {
            _timer.fireDate = Date.distantPast
        } else {
            state = .fire
        }
    }
    
    func suspend() {
        if let _timer = timer {
            _timer.fireDate = Date.distantFuture
        } else {
            state = .suspend
        }
    }
    
    func invalidate() {
        timer?.invalidate()
    }
    
    deinit {
        invalidate()
        print("--------WeakTargetProxy-----deinit------------")
    }
}
