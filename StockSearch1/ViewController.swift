//
//  ViewController.swift
//  StockSearch1
//
//  Created by Maglly on 7/30/20.
//  Copyright © 2020 Maglly. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var searchTextfield: UITextField!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var pricelabel: UILabel!
    
    var stocks:Stock?
    var timer: DispatchSourceTimer?
    //
    var startTimestamp: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextfield.delegate = self
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.stopTimer()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTextfield.resignFirstResponder()
        //searchStocks
        guard let text = self.searchTextfield.text,  !text.isEmpty  else {
            return true
        }
        let query = text.uppercased()
        self.symbolLabel.text = query
        startTimer(query:query)
        //
        startTimestamp = Date()
        return true
    }

    func searchStocks(query:String) {
        // btc url = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD"
        URLSession.shared.dataTask(with: URL(string: "https://finnhub.io/api/v1/quote?symbol=\(query)&token=bse6ah7rh5rea8raaqog")!,
                                   completionHandler: { data, response, error in
                                    
                                    guard let data = data, error == nil else {
                                        return
                                    }
                                    // Convert to Swift Objects
                                    var result: Stock?
                                    do {
                                        result = try JSONDecoder().decode(Stock.self, from: data)
                                    }
                                    catch {
                                        print("error")
                                    }
                                    guard let finalResult = result else {
                                        return
                                    }
                                    // Update  stocks
                                    let stockCurrentPrice = finalResult.c
                                    DispatchQueue.main.async {
                                        print("am i in main thread \(Thread.isMainThread)")
                                        self.pricelabel.text = "$\(String(stockCurrentPrice))"
                                        //
                                        UIView.animate(withDuration: 0.5, animations: {
                                            self.pricelabel.frame.origin.x += 5
                                            self.pricelabel.textColor = .red
                                        }) { (true) in
                                            self.pricelabel.frame.origin.x -= 5
                                            self.pricelabel.textColor = .white
                                        }
                                    }
        }).resume()
    }
    

    func startTimer(query:String) {
        let queue = DispatchQueue(label: "com.stock.search.timer", attributes: .concurrent)
        
        timer?.cancel()   // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: .now() , repeating: .seconds(3), leeway: .milliseconds(100))
                
        timer?.setEventHandler { [weak self] in // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            //self?.searchStocks(query: query)
            //stop timer after a point
            if Date().timeIntervalSince((self?.startTimestamp!)!) < 50 {
                self?.searchStocks(query: query) //Api Call
            } else {
                print("Timeout error")
                DispatchQueue.main.async {
                     self?.stopTimer()
                }
            }
        }
        timer?.resume()
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    
    
}

