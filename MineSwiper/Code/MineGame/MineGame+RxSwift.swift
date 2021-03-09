//
//  MineGame+RxSwift.swift
//  MineSwiper
//
//  Created by my on 2021/3/8.
//  Copyright © 2021 MZ. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class _MineGameDelegateProxy: MineGameDelegate {
    typealias StateDidChanged = (MineGame.State) -> Void
    typealias PlayingCount = (TimeInterval) -> Void
    typealias FlagLocation = (MineGame.Location) -> Void
    typealias UncoverLocation = (MineGame.Location, MineItem) -> Void
    typealias GameOver = (MineGame.Result) -> Void

    var stateDidChanged: StateDidChanged = { _ in }
    var playingCount: PlayingCount = { _ in }
    var flagLocation: FlagLocation = { _ in }
    var uncoverLocation: UncoverLocation = { _, _ in }
    var gameOver: GameOver = { _ in }
    
    func mineGameDidPrepared(_ game: MineGame) {
        self.stateDidChanged(game.state)
    }
    
    func mineGame(_ game: MineGame, didFlagLocation location: MineGame.Location) {
        self.flagLocation(location)
    }
    
    func mineGame(_ game: MineGame, didUncoverLocation location: MineGame.Location, with item: MineItem) {
        self.uncoverLocation(location, item)
    }
    
    func mineGameDidEnd(_ game: MineGame, result: MineGame.Result) {
        self.stateDidChanged(game.state)
    }
    
    func mineGame(_ game: MineGame, didPlayingTimeinterval: TimeInterval) {
        self.stateDidChanged(game.state)
        self.playingCount(didPlayingTimeinterval)
    }
}

internal final class MineGameDelegateProxy: _MineGameDelegateProxy {
    
    enum Action: String {
        case stateDidChanged
        case playingCount
        case flagLocation
        case uncoverLocation
        case gameOver
    }
    
    private final class ActionDispather {
        let subject: PublishSubject<[Any]> = PublishSubject()
        
        var on: (Event<[Any]>) -> Void {
            return self.subject.on
        }
        
        func asObservable() -> Observable<[Any]> {
            return self.subject.share()
        }
    }
    
    private var actions: [Action: ActionDispather] = [:]

    override init() {
        super.init()
        self.stateDidChanged = { [unowned self] in
            self.forwardMethod(.stateDidChanged, with: [$0])
        }
        
        self.playingCount = { [unowned self] in
            self.forwardMethod(.playingCount, with: [$0])
        }
        
        self.flagLocation = { [unowned self] in
            self.forwardMethod(.flagLocation, with: [$0])
        }
        
        self.uncoverLocation = { [unowned self] in
            self.forwardMethod(.uncoverLocation, with: [$0, $1])
        }
        
        self.gameOver = { [unowned self] in
            self.forwardMethod(.gameOver, with: [$0])
        }
    }
    
    private func forwardMethod(_ selector: Action, with arguments: [Any]) {
        actions[selector]?.on(.next(arguments))
    }
    
    func methodInvoke(_ selector: Action) -> Observable<[Any]> {
        if let dispatcher = actions[selector] {
            return dispatcher.asObservable()
        } else {
            let _dispatcher = ActionDispather()
            actions[selector] = _dispatcher
            return _dispatcher.asObservable()
        }
    }
    
    deinit {
        actions.values.forEach({
            $0.on(.completed)
        })
    }
}

extension MineGame: ReactiveCompatible {}

extension Reactive where Base: MineGame {
    
    var mineItems: Observable<[[MineItem]]> {
        let _state = state.map({ _ in base.mineItems })
        let _flagLocation = flagLocation.map({ _ in base.mineItems })
        let _uncoverLocation = uncoverLocation.map({ _ in base.mineItems })
        return Observable.merge(_state, _flagLocation, _uncoverLocation)
    }
    
    var delegate: MineGameDelegateProxy {
        if let _delegate = base.delegate as? MineGameDelegateProxy {
            return _delegate
        } else {
            let _delegate = MineGameDelegateProxy()
            base.delegate = _delegate
            let delegateIdentifier = ObjectIdentifier(MineGameDelegate.self)
            let integerIdentifier = Int(bitPattern: delegateIdentifier)
            let identifier = UnsafeRawPointer(bitPattern: integerIdentifier)!
            objc_setAssociatedObject(base, identifier, _delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return _delegate
        }
    }
        
    var state: Observable<MineGame.State> {
        return self.delegate.methodInvoke(.stateDidChanged).map({
            if let state = $0[0] as? MineGame.State {
                return state
            } else {
                fatalError()
            }
        })
    }
    
    var playingTimeInterval: Observable<TimeInterval> {
        return self.delegate.methodInvoke(.playingCount).map({
            if let count = $0[0] as? TimeInterval {
                return count
            } else {
                fatalError()
            }
        })
    }
    
    var flagLocation: Observable<MineGame.Location> {
        return self.delegate.methodInvoke(.flagLocation).map({
            if let location = $0[0] as? MineGame.Location {
                return location
            } else {
                fatalError()
            }
        })
    }
    
    var uncoverLocation: Observable<(MineGame.Location, MineItem)> {
        return self.delegate.methodInvoke(.uncoverLocation).map({
            if let location = $0[0] as? MineGame.Location, let item = $0[1] as? MineItem {
                return (location, item)
            } else {
                fatalError()
            }
        })
    }
    
    var gameOver: Observable<MineGame.Result> {
        return self.delegate.methodInvoke(.gameOver).map({
            if let result = $0[0] as? MineGame.Result {
                return result
            } else {
                fatalError()
            }
        })
    }
    
    var flagLocationAction: Binder<Int> {
        return Binder(base) { game, location in
            game.flagLocation(MineGame.Location(x: location / base.map.height, y: location % base.map.height))
        }
    }
    
    var uncoverLocationActions: Binder<Int> {
        return Binder(base) { game, location in
            game.uncoverLocation(MineGame.Location(x: location / base.map.height, y: location % base.map.height))
        }
    }
}
