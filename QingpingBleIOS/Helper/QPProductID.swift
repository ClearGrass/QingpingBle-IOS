//
//  QPProductID.swift
//  QingpingBleIOS
//
//  Created by Tiger on 2022/8/30.
//  青萍 各个产品对应的产品id（用于蓝牙扫描时过滤设备）
//  根据产品型号来查各个产品对应的产品ID（产品型号通常印在产品的机身）
//

import Foundation

class QPProductID {
    //青萍温湿度气压计 Wi-Fi 版  型号 Model：CGP1W
    public static let CGP1W = 0x09;
    
    //青萍温湿度气压计 NB-IoT 版 型号 Model： CGP1N
    public static let CGP1N = 0x0a;
    
    //青萍温湿度气压计 LoRa 版，型号 Model：CGP1L
    public static let CGP1L = 0x0b;
    
    //青萍商用温湿度气压计 S 低温带气压 Wi-Fi版，型号 Model： CGP23W
    public static let CGP23W = 0x18;
    
    //青萍商用温湿度气压计 S 低温带气压NB-IoT版，型号 Model：CGP23N
    public static let CGP23N = 0x19;
    
    //青萍商用温湿度气压计 S 低温带气压LoRa版，型号 Model：CGP23N
    public static let CGP23L = 0x1a;
    
    //青萍商用温湿度计 S 常温不带气压Wi-Fi版，型号 Model：CGP22W
    public static let CGP22W = 0x1b;
    
    //青萍商用温湿度计 S 常温不带气压NB-IoT版 型号 Model：CGP22N
    public static let CGP22N = 0x1c;
    
    //青萍商用温湿度计 S 常温不带气压LoRa版 型号 Model：CGP22L
    public static let CGP22L = 0x1d;
    
    //青萍商用温湿度计 E Wi-Fi 版， 型号 Model：CGF1W
    public static let CGF1W = 0x15;
    
    //青萍商用温湿度计 E NB-IoT 版， 型号 Model：CGF1N
    public static let CGF1N = 0x13;
    
    //青萍商用温湿度计 E LoRa 版， 型号 Model：CGF1L
    public static let CGF1L = 0x14;
    
    //青萍空气检测仪 Lite，型号 Model： CGDN1
    public static let CGDN1 = 0x0e;
    
}
