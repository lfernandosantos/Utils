//
//  Utils.swift
//  
//
//  Created by Luiz Fernando on 08/02/19.
//

import Foundation


enum CRCType {
    case MODBUS
    case ARC
}


class CalcCRC16 {
    func crcXModem( bytes: [UInt8]) {
        var crc: UInt16 = 0x0000          // initial value
        let polynomial: UInt16 = 0x1021   // 0001 0000 0010 0001  (0, 5, 12)
        
        for by in bytes {
            
            for i in 0..<8 {
                let bit = ((by  >> (7-i) & 1) == 1)
                let c15 = ((crc >> 15    & 1) == 1)
                
                crc <<= 1
                
                if (c15 != bit) {
                    crc ^= polynomial
                }
            }
            crc &= 0xffff
        }
        
        return crc
    }
    
    
    func crcArcModbus(_ data: [UInt8], type: CRCType) -> UInt16? {
        if data.isEmpty {
            return nil
        }
        let polynomial: UInt16 = 0xA001 // A001 is the bit reverse of 8005
        var accumulator: UInt16
        // set the accumulator initial value based on CRC type
        if type == .ARC {
            accumulator = 0
        }
        else {
            // default to MODBUS
            accumulator = 0xFFFF
        }
        // main computation loop
        for byte in data {
            var tempByte = UInt16(byte)
            for _ in 0 ..< 8 {
                let temp1 = accumulator & 0x0001
                accumulator = accumulator >> 1
                let temp2 = tempByte & 0x0001
                tempByte = tempByte >> 1
                if (temp1 ^ temp2) == 1 {
                    accumulator = accumulator ^ polynomial
                }
            }
        }
        return accumulator
    }
}
