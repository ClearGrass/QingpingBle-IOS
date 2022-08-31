//
//  QPUUID.swift
//  QingpingBleIOS
//
//  Created by Tiger on 2022/8/30.
//

import Foundation
import CoreBluetooth

struct QPUUID {
    static let QP_UUID = CBUUID(string: "fdcd")
    static let qp_service_uuid = CBUUID(string: "22210000-554a-4546-5542-46534450464d")
    
    static let base_write_characteristic = CBUUID(string: "0001")
    static let base_notify_characteristic = CBUUID(string: "0002")
    
    static let my_write_characteristic = CBUUID(string: "000d")
    static let my_notify_characteristic = CBUUID(string: "000e")

}
