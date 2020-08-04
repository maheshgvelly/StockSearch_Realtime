//
//  TimerUtil.swift
//  StockSearch1
//
//  Created by Maglly on 7/30/20.
//  Copyright © 2020 Maglly. All rights reserved.
//

import Foundation

protocol TimerObserver: class {
    func searchStocks()
}

final class StockTimer {
    private var timer: Timer?
    static private let sharedInstance: StockTimer = StockTimer()
    weak var target: TimerObserver?
    
    private init() { }
    
    static func shared() -> StockTimer {
        return sharedInstance
    }
    
    func createTimer(selector: Selector) {
        if timer == nil {
            guard let timerTarget = target else {
                return
            }
            
            let timer = Timer(timeInterval: 1.0, target: timerTarget, selector: selector, userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            self.timer = timer
            print("timer is created")
            //self.timer?.fire()
        }
    }

    func cancelTimer() {
        DispatchQueue.main.async {
            print(Thread.isMainThread)
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}


// repeated timer -- battery
