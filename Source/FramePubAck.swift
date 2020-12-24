//
//  FramePuback.swift
//  CocoaMQTT
//
//  Created by JianBo on 2019/8/7.
//  Copyright © 2019 emqx.io. All rights reserved.
//

import Foundation


/// MQTT PUBACK packet
struct FramePubAck: Frame {
    
    var fixedHeader: UInt8 = FrameType.puback.rawValue

    // --- Attributes
    
    var msgid: UInt16
    var _payload: [UInt8] = []
    
    // --- Attributes End
    
    init(msgid: UInt16, payload: [UInt8]) {
        self.msgid = msgid
        self._payload = payload
    }
}

extension FramePubAck {
    
    func variableHeader() -> [UInt8] { return msgid.hlBytes }
    
    func payload() -> [UInt8] { return _payload }
}

extension FramePubAck: InitialWithBytes {
    
    init?(fixedHeader: UInt8, bytes: [UInt8]) {
        guard fixedHeader == FrameType.puback.rawValue else {
            return nil
        }
        guard bytes.count >= 2 else {
            return nil
        }
        
        msgid = UInt16(bytes[0]) << 8 + UInt16(bytes[1])
        
        let msb2 = bytes[2]
        let msb1 = bytes[3]
        let lsb2 = bytes[4]
        let lsb1 = bytes[5]
        
        if (2 < bytes.count) {
            _payload = [UInt8](bytes[2..<bytes.count])
        }
        
    }
}

extension FramePubAck: CustomStringConvertible {
    var description: String {
        return "PUBACK(id: \(msgid))"
    }
}
