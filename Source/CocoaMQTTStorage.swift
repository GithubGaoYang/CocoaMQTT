//
//  CocoaMQTTStorage.swift
//  CocoaMQTT
//
//  Created by JianBo on 2019/10/6.
//  Copyright © 2019 emqtt.io. All rights reserved.
//

import Foundation
import CommonCrypto

protocol CocoaMQTTStorageProtocol {
    
    var clientId: String { get set }
    
    init?(by clientId: String)
    
    func write(_ frame: FramePublish) -> Bool
    
    func write(_ frame: FramePubRel) -> Bool
    
    func remove(_ frame: FramePublish)
    
    func remove(_ frame: FramePubRel)
    
    func synchronize() -> Bool
    
    /// Read all stored messages by saving order
    func readAll() -> [Frame]
}

final class CocoaMQTTStorage: CocoaMQTTStorageProtocol {
    
    var clientId: String
    
    var userDefault: UserDefaults

    init?(by clientId: String) {
        guard let userDefault = UserDefaults(suiteName: CocoaMQTTStorage.name(clientId)) else {
            return nil
        }
        
        self.clientId = clientId
        self.userDefault = userDefault
    }
    
    deinit {
        userDefault.synchronize()
    }
    
    func write(_ frame: FramePublish) -> Bool {
        guard frame.qos > .qos0 else {
            return false
        }
        userDefault.set(frame.bytes(), forKey: key(frame.msgid))
        return true
    }
    
    func write(_ frame: FramePubRel) -> Bool {
        userDefault.set(frame.bytes(), forKey: key(frame.msgid))
        return true
    }
    
    func remove(_ frame: FramePublish) {
        userDefault.removeObject(forKey: key(frame.msgid))
    }
    
    func remove(_ frame: FramePubRel) {
        userDefault.removeObject(forKey: key(frame.msgid))
    }
    
    func remove(_ frame: Frame) {
        if let pub = frame as? FramePublish {
            userDefault.removeObject(forKey: key(pub.msgid))
        } else if let rel = frame as? FramePubRel {
            userDefault.removeObject(forKey: key(rel.msgid))
        }
    }
    
    func synchronize() -> Bool {
        return userDefault.synchronize()
    }
    
    func readAll() -> [Frame] {
        return __read(needDelete: false)
    }
    
    func takeAll() -> [Frame] {
        return __read(needDelete: true)
    }
    
    private func key(_ msgid: UInt16) -> String {
        return "\(msgid)"
    }
    
    private class func name(_ clientId: String) -> String {
        return "cocomqtt-\(clientId.md5)"
    }
    
    private func parse(_ bytes: [UInt8]) -> (UInt8, [UInt8])? {
        /// bytes 1..<5 may be 'Remaining Length'
        for i in 1 ..< 5 {
            if (bytes[i] & 0x80) == 0 {
                return (bytes[0], Array(bytes.suffix(from: i+1)))
            }
        }
        
        return nil
    }
    
    private func __read(needDelete: Bool)  -> [Frame] {
        var frames = [Frame]()
        let allObjs = userDefault.dictionaryRepresentation().sorted { (k1, k2) in
            return k1.key < k2.key
        }
        for (k, v) in allObjs {
            guard let bytes = v as? [UInt8] else { continue }
            guard let parsed = parse(bytes) else { continue }

            if needDelete {
                userDefault.removeObject(forKey: k)
            }

            if let f = FramePublish(fixedHeader: parsed.0, bytes: parsed.1) {
                frames.append(f)
            } else if let f = FramePubRel(fixedHeader: parsed.0, bytes: parsed.1) {
                frames.append(f)
            }
        }
        return frames
    }
    
}

extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
}
