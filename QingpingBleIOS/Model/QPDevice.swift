//
//  QPDevice.swift
//  QingpingBleIOS
//
//  Created by Tiger on 2022/8/30.
//

import Foundation
import CoreBluetooth

class QPDevice {
    // 设备 mac 地址
    var mac:String  = ""
    // 设备 productID 见 QPProductID
    var productID:UInt8 = 0x0
    // 是否是绑定包
    var isBind:Bool = false
    
    init(_ fdcdData: Data) {
        print("解析前：", fdcdData.hexData)
        
        //Frame Control（1字节）+ Product(1字节） + mac地址（6字节）最少需要 8 字节
        guard fdcdData.count >= 8 else {return }
        
        
        let isBind = (fdcdData[0] & 0x2) > 0
        let productID =  fdcdData[1]
        
        var mac:String = ""
        for index in 2...7 {
            mac.insert(contentsOf: String(format: "%02x", fdcdData[index]), at: mac.startIndex)
        }
        
        self.productID = productID
        self.isBind = isBind
        self.mac = mac.uppercased()
        
        print("解析后 mac:\(self.mac), productId:\(self.productID), isBind:\(isBind)")
    }
}
