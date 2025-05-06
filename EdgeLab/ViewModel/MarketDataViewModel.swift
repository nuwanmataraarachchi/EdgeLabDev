//
//  MarketDataViewModel.swift
//  EdgeLab
//
//  Created by user270106 on 2025-05-05.
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
            fetchStockData(symbols: symbols)
            return
        }
        
        isLoading = true
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        let authMessage = "{\"action\":\"auth\",\"params\":\"\(apiKey)\"}"
        let subscribeMessage = "{\"action\":\"subscribe\",\"params\":\"T.\(symbols.joined(separator: ",T."))\"}"
        
        print("Connecting to WebSocket with auth: \(authMessage)")
        print("Subscribing to: \(subscribeMessage)")
        sendWebSocketMessage(authMessage)
        sendWebSocketMessage(subscribeMessage)
        
        receiveWebSocketMessages()
    }
    
    func reconnectWebSocket(symbols: [String], retryCount: Int = 3) {
        guard retryCount > 0 else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to reconnect WebSocket after multiple attempts"
                self.fetchStockData(symbols: symbols)
            }
            return
        }
        print("Retrying WebSocket connection, attempts left: \(retryCount)")
        connectWebSocket(symbols: symbols)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.webSocketTask?.state != .running {
                self.reconnectWebSocket(symbols: symbols, retryCount: retryCount - 1)
            }
        }
    }
    
    private func sendWebSocketMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "WebSocket send error: \(error.localizedDescription)"
                    print("WebSocket send error: \(error.localizedDescription)")
                    let symbols = self.stockData.map({ $0.symbol }).uniqued()
                    self.reconnectWebSocket(symbols: Array(symbols))
                }
            } else {
                print("WebSocket message sent successfully: \(message)")
            }
        }
    }
    
    private func receiveWebSocketMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received WebSocket message: \(text)")
                    self?.handleWebSocketMessage(text)
                case .data:
                    print("Received data message")
                @unknown default:
                    break
                }
                self?.receiveWebSocketMessages()
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "WebSocket receive error: \(error.localizedDescription)"
                    print("WebSocket receive error: \(error.localizedDescription)")
                    let symbols = self?.stockData.map({ $0.symbol }).uniqued() ?? []
                    self?.reconnectWebSocket(symbols: Array(symbols))
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: String) {
        print("Raw WebSocket message received: \(message)")
        
        guard let data = message.data(using: .utf8) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid message data"
                print("Failed to convert message to data")
            }
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Parsed JSON object: \(json)")
                
                if let event = json["ev"] as? String {
                    print("Event type: \(event)")
                }
                
                if let event = json["ev"] as? String, event == "T",
                   let symbol = json["sym"] as? String,
                   let price = json["p"] as? Double,
                   let timestamp = json["t"] as? Int64 {
                    print("Processing trade data - Symbol: \(symbol), Price: \(price), Timestamp: \(timestamp)")
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000)) // Milliseconds to seconds
                    print("Converted date: \(date)")
                    
                    let stock = StockData(symbol: symbol, price: price, timestamp: date)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.updateStockData(stock)
                        print("Updated stock data for \(symbol): \(price)")
                    }
                } else if let status = json["status"] as? String {
                    print("Status message received: \(status)")
                    if status == "error" {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.errorMessage = "API error: \(json["message"] as? String ?? "Unknown error")"
                            print("API error: \(json["message"] as? String ?? "Unknown error")")
                        }
                    } else if status == "connected" {
                        print("WebSocket connected successfully")
                    }
                }
            } else if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                print("Parsed JSON array with \(jsonArray.count) items")
                
                for item in jsonArray {
                    print("Processing array item: \(item)")
                    
                    if let event = item["ev"] as? String, event == "T",
                       let symbol = item["sym"] as? String,
                       let price = item["p"] as? Double,
                       let timestamp = item["t"] as? Int64 {
                        print("Processing trade data from array - Symbol: \(symbol), Price: \(price), Timestamp: \(timestamp)")
                        
                        let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000)) // Milliseconds to seconds
                        print("Converted date: \(date)")
                        
                        let stock = StockData(symbol: symbol, price: price, timestamp: date)
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.updateStockData(stock)
                            print("Updated stock data for \(symbol): \(price)")
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "JSON parsing error: \(error.localizedDescription)"
                print("JSON parsing error: \(error.localizedDescription)")
                print("Failed to parse message: \(message)")
            }
        }
    }
    
    private func updateStockData(_ newStock: StockData) {
        print("Updating stock data - Current count: \(stockData.count)")
        stockData.append(newStock)
        stockData.sort { $0.timestamp < $1.timestamp } // Sort by timestamp for charts
        // Limit to last 100 entries to prevent memory issues
        if stockData.count > 100 {
            stockData.removeFirst(stockData.count - 100)
        }
        print("Updated stock data - New count: \(stockData.count)")
        print("Current stock data: \(stockData.map { "\($0.symbol): \($0.price)" })")
    }
    
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("WebSocket disconnected")
    }
    
    func fetchStockData(symbols: [String]) {
        isLoading = true
        let symbolsString = symbols.joined(separator: ",")
        guard let url = URL(string: "https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers?tickers=\(symbolsString)&apiKey=\(apiKey)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid REST URL"
                self.isLoading = false
            }
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
                print("Fetched stock data via REST: \(newStockData.map { "\($0.symbol): \($0.price)" })")
            }
        }.resume()
    }
}

// Extension to get unique elements from a sequence
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
