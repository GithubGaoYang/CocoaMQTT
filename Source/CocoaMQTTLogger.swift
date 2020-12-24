//
//  CocoaMQTTLogger.swift
//  CocoaMQTT
//
//  Created by HJianBo on 2019/5/2.
//  Copyright © 2019 emqx.io. All rights reserved.
//

import Foundation

// Convenience functions
func printDebug(_ message: String) {
    CocoaMQTTLogger.logger.debug(message)
}

func printInfo(_ message: String) {
    CocoaMQTTLogger.logger.info(message)
}

func printWarning(_ message: String) {
    CocoaMQTTLogger.logger.warning(message)
}

func printError(_ message: String) {
    CocoaMQTTLogger.logger.error(message)
}


// Enum log levels
public enum CocoaMQTTLoggerLevel: Int {
    case debug = 0, info, warning, error, off
}


open class CocoaMQTTLogger: NSObject {
    
    // Singleton
    public static var logger = CocoaMQTTLogger()
    public override init() { super.init() }

    // min level
    var minLevel: CocoaMQTTLoggerLevel = .warning
    
    // logs
    open func log(level: CocoaMQTTLoggerLevel, message: String) {
        guard level.rawValue >= minLevel.rawValue else { return }
        
        var symbol: String
        var description: String
        switch level {
        case .debug:
            symbol = "🛠"
            description = "DEBUG"
        case .info:
            symbol = "📝"
            description = "INFO"
        case .warning:
            symbol = "⚠️"
            description = "WARNING"
        case .error:
            symbol = "❌"
            description = "ERROR"
        case .off:
            symbol = ""
            description = "OFF"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        print("\(dateFormatter.string(from: Date())) \(symbol) \(description) CocoaMQTT: \(message)")
    }
    
    func debug(_ message: String) {
        log(level: .debug, message: message)
    }
    
    func info(_ message: String) {
        log(level: .info, message: message)
    }
    
    func warning(_ message: String) {
        log(level: .warning, message: message)
    }
    
    func error(_ message: String) {
        log(level: .error, message: message)
    }
    
}
