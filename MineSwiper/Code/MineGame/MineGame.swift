//
//  MineGame.swift
//  MineSwiper
//
//  Created by my on 2021/3/8.
//  Copyright © 2021 MZ. All rights reserved.
//

import Foundation

enum MineItem {
    enum Status {
        case flag
        case `default`
    }
    case covered(Status)
    
    enum State {
        case number(Int)
        case mine
        case currentMine
        case flagWrong
    }
    case uncovered(State)
}

protocol MineGameDelegate: class {
    func mineGameDidPrepared(_ game: MineGame)
    func mineGame(_ game: MineGame, didFlagLocation location: MineGame.Location)
    func mineGame(_ game: MineGame, didUncoverLocation location: MineGame.Location, with item: MineItem)
    func mineGameDidEnd(_ game: MineGame, result: MineGame.Result)
    func mineGame(_ game: MineGame, didPlayingTimeinterval: TimeInterval)
}

internal final class MineGame {
    struct Map {
        let mines: Int
        let width: Int
        let height: Int
        
        static let `default` = Map(mines: 10, width: 9, height: 9)
        static let middle = Map(mines: 40, width: 16, height: 16)
        static let big = Map(mines: 99, width: 30, height: 16)
    }
    
    struct Location {
        let x: Int
        let y: Int
    }
    
    enum Result {
        case success
        case failure
    }
    
    enum State {
        case prepared
        case playing(Int)
        case end
    }
    
    private var timer: Timer?
    
    private(set) var playTimeinterval: Int = 0
    
    private(set) var state: State = .prepared
    
    weak var delegate: MineGameDelegate?
    
    private(set) var gameTimer: ThreadTimer?
    
    private(set) var mineItems: [[MineItem]] = [[]]
    private(set) var mineLocations: [Int] = []
    private(set) var flagLocations: [Int] = []
    var flags: Int {
        return map.mines - flagLocations.count
    }
    
    var map: Map {
        didSet {
            self.uploadMineItems(with: map)
        }
    }
    init(map: Map = Map.default) {
        self.map = map
    }
    
    private func uploadMineItems(with map: Map) {
        let total = map.width * map.height
        guard total > 0 else { fatalError() }
        
        mineItems = Array(repeating: Array(repeating: .covered(.default), count: map.height), count: map.width)
        mineLocations = []
        flagLocations = []
        playTimeinterval = 0
        
        var set: [Int] = []
        for count in 0 ..< total {
            set.append(count)
        }
        
        for _ in 0 ..< map.mines {
            let randomIndex = Int(arc4random()) % set.count
            let location = set.remove(at: randomIndex)
            mineLocations.append(location)
        }
        state = .prepared
        gameTimer?.invalidate()
        delegate?.mineGameDidPrepared(self)
    }
    
    func start() {
        uploadMineItems(with: map)
    }
    
    private func _startGameIfPrepared() {
        guard case .prepared = state else { return }
        state = .playing(0)
        _startTimer()
    }
    
    private func _startTimer() {
        gameTimer = ThreadTimer(action: { [weak self] _ in
            guard let wself = self else { return }
            wself.state = .playing(wself.playTimeinterval)
            wself.delegate?.mineGame(wself, didPlayingTimeinterval: TimeInterval(wself.playTimeinterval))
            wself.playTimeinterval += 1
        })
        gameTimer?.fire()
    }
    
    func flagLocation(_ location: Location) {
        _startGameIfPrepared()
        let item = mineItems[location.x][location.y]
        switch item {
        case .covered(.default) where flagLocations.count < map.mines:
            mineItems[location.x][location.y] = .covered(.flag)
            flagLocations.append(location.x * map.height + location.y)
            delegate?.mineGame(self, didFlagLocation: location)
        case .covered(.flag):
            mineItems[location.x][location.y] = .covered(.default)
            flagLocations.removeAll(where: { $0 == location.x * map.height + location.y })
            delegate?.mineGame(self, didFlagLocation: location)
        default:
            break
        }
    }
    
    func uncoverLocation(_ location: Location) {
        _startGameIfPrepared()
        let item = mineItems[location.x][location.y]
        if !canUncoverItemAtLocation(location) {
            mineItems[location.x][location.y] = .uncovered(.currentMine)
            endGameWithResult(.failure)
            return
        }

        switch item {
        case .covered(.default):
            _uncoverLocation(location)
            delegate?.mineGame(self, didUncoverLocation: location, with: item)
        default:
            break
        }
    }
    
    private func _uncoverLocation(_ location: Location) {
        guard location.x >= 0, location.y >= 0, location.x < mineItems.count, location.y < mineItems[location.x].count else { return }
        let item = mineItems[location.x][location.y]
        switch item {
        case .covered(.default):
            let count = countMinesArroundLocation(location)
            mineItems[location.x][location.y] = .uncovered(.number(count))
            print("--------_uncoverLocation ----------------\(location)-------------")
            if count == 0 {
                _uncoverLocation(Location(x: location.x - 1, y: location.y - 1))
                _uncoverLocation(Location(x: location.x, y: location.y - 1))
                _uncoverLocation(Location(x: location.x + 1, y: location.y - 1))
                _uncoverLocation(Location(x: location.x - 1, y: location.y))
                _uncoverLocation(Location(x: location.x + 1, y: location.y))
                _uncoverLocation(Location(x: location.x - 1, y: location.y + 1))
                _uncoverLocation(Location(x: location.x, y: location.y + 1))
                _uncoverLocation(Location(x: location.x + 1, y: location.y + 1))
            }
        default:
            break
        }
    }
    
    private func countMinesArroundLocation(_ location: Location) -> Int {
        var count: Int = 0
        count += locationIsMine(Location(x: location.x - 1, y: location.y - 1))
        count += locationIsMine(Location(x: location.x, y: location.y - 1))
        count += locationIsMine(Location(x: location.x + 1, y: location.y - 1))
        count += locationIsMine(Location(x: location.x - 1, y: location.y))
        count += locationIsMine(Location(x: location.x + 1, y: location.y))
        count += locationIsMine(Location(x: location.x - 1, y: location.y + 1))
        count += locationIsMine(Location(x: location.x, y: location.y + 1))
        count += locationIsMine(Location(x: location.x + 1, y: location.y + 1))
        return count
    }
    
    private func locationIsMine(_ location: Location) -> Int {
        guard location.x >= 0, location.y >= 0, location.x < mineItems.count, location.y < mineItems[location.x].count else { return 0 }
        return canUncoverItemAtLocation(location) ? 0 : 1
    }
    
    private func canUncoverItemAtLocation(_ location: Location) -> Bool {
        let _location = location.x * map.height + location.y
        return !mineLocations.contains(_location)
    }
    
    private func endGameWithResult(_ result: Result) {
        _endGame()
        switch result {
        case .success:
            break
        case .failure:
            for location in mineLocations {
                let x = location / map.height
                let y = location % map.height
                if case .uncovered(.currentMine) = mineItems[x][y] {
                    continue
                }
                mineItems[x][y] = .uncovered(.mine)
            }
            
            for location in flagLocations {
                let x = location / map.height
                let y = location % map.height
                if case .uncovered(.mine) = mineItems[x][y] {
                    continue
                }
                mineItems[x][y] = .uncovered(.flagWrong)
            }
        }
        delegate?.mineGameDidEnd(self, result: result)
    }
    
    private func _endGame() {
        state = .end
        gameTimer?.invalidate()
    }
}


