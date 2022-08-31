//
//  Util.swift
//  QingpingBleIOS
//
//  Created by Tiger on 2022/8/30.
//

import Foundation
import RxBluetoothKit

class Util {
    static func parsePeripherals(_ fdcdData: Data) -> QPDevice? {
        print("解析前：", fdcdData.hexData)
        
        //Frame Control（1字节）+ Product(1字节） + mac地址（6字节）最少需要 8 字节
        guard fdcdData.count >= 8 else {return nil}
        
        
        let isBind = (fdcdData[0] & 0x2) > 0
        let productID =  fdcdData[1]
        
        var mac:String = ""
        for index in 2...7 {
            mac.insert(contentsOf: String(format: "%02x", fdcdData[index]), at: mac.startIndex)
        }
        
        let device = QPDevice(mac: mac, productID: productID, isBind: isBind)
        print("解析后：", device)
        return device
    }
}

