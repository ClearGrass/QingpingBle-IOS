//
//  QPDevice.swift
//  QingpingBleIOS
//
//  Created by Tiger on 2022/8/30.
//

import Foundation

struct QPDevice {
    // 设备 mac 地址
    var mac:String
    // 设备 productID 见 QPProductID
    var productID:UInt8
    // 是否是绑定包
    var isBind:Bool
}
