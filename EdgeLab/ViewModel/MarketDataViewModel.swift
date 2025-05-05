//
//  MarketDataViewModel.swift
//  EdgeLab
//
//  Created on 2025-05-05.
//

import Foundation

class MarketDataViewModel: ObservableObject {
    @Published var stockData: [StockData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    private var webSocketTask: URLSessionWebSocketTask?
    private let apiKey = "bPCoxIUv17igqM3HzGQk3Uj9LBWfZrMx"
    
    init() {}
    
    func connectWebSocket(symbols: [String]) {
        guard let url = URL(string: "wss://socket.polygon.io/stocks?apiKey=\(apiKey)") else {
            self.errorMessage = "Invalid WebSocket URL"
            fetchStockData(symbols: symbols) // Fallback to REST
            return
        }
        
        isLoading = true
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Authenticate and subscribe to symbols
        let authMessage = "{\"action\":\"auth\",\"params\":\"\(apiKey)\"}"
        let subscribeMessage = "{\"action\":\"subscribe\",\"params\":\"T.\(symbols.joined(separator: ",T."))\"}"
        
        sendWebSocketMessage(authMessage)
        sendWebSocketMessage(subscribeMessage)
        
        receiveWebSocketMessages()
    }
    
    private func sendWebSocketMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "WebSocket send error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func receiveWebSocketMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleWebSocketMessage(text)
                case .data:
                    print("Received data message")
                @unknown default:
                    break
                }
                self?.receiveWebSocketMessages() // Continue listening
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "WebSocket receive error: \(error.localizedDescription)"
                    // Optionally retry with REST
                    if let symbols = self?.stockData.map({ $0.symbol }) {
                        self?.fetchStockData(symbols: symbols)
                    }
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonArray = json as? [[String: Any]] else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid data format"
            }
            return
        }
        
        for item in jsonArray {
            if let event = item["ev"] as? String, event == "T",
               let symbol = item["sym"] as? String,
               let price = item["p"] as? Double,
               let timestamp = item["t"] as? Int64 {
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
                let stock = StockData(symbol: symbol, price: price, timestamp: date)
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Append and keep only the latest 100 entries per symbol
                    self.stockData.append(stock)
                    self.stockData = self.stockData
                        .filter { $0.symbol == stock.symbol }
                        .suffix(100)
                        .sorted { $0.timestamp < $1.timestamp }
                        + self.stockData.filter { $0.symbol != stock.symbol }
                }
            } else if item["status"] as? String == "error" {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "API error: \(item["message"] as? String ?? "Unknown error")"
                }
            }
        }
    }
    
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func fetchStockData(symbols: [String]) {
        isLoading = true
        let symbolsString = symbols.joined(separator: ",")
        guard let url = URL(string: "https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers?tickers=\(symbolsString)&apiKey=\(apiKey)") else {
            self.errorMessage = "Invalid REST URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []),
                  let jsonDict = json as? [String: Any],
                  let tickers = jsonDict["tickers"] as? [[String: Any]] else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Invalid data format"
                }
                return
            }
            
            var newStockData: [StockData] = []
            for ticker in tickers {
                if let symbol = ticker["ticker"] as? String,
                   let lastTrade = ticker["lastTrade"] as? [String: Any],
                   let price = lastTrade["p"] as? Double {
                    let stock = StockData(symbol: symbol, price: price, timestamp: Date())
                    newStockData.append(stock)
                }
            }
            
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.stockData = newStockData
            }
        }.resume()
    }
}
