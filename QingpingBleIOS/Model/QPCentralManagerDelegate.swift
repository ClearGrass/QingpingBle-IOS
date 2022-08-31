//
//  QPCentralManagerDelegate.swift
//  QingpingBleIOS
//
//  Created by Tiger on 2022/8/31.
//

import Foundation
import CoreBluetooth


class QPCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    var myCentralManager:CBCentralManager!
    var peripheralDelegate: QPPeripheralDelegate!
    var currentDevice:QPDevice!
    
    override init() {
        peripheralDelegate = QPPeripheralDelegate()
    }
    
    /**
     * 连接流程是：
     * 1. 开始扫描
     * 2. 扫描到目标设备（解析后的isBind为true——即为绑定包，且 productId为 青萍空气检测仪 Lite）
     * 3. 连接设备
     * 4. 发现青萍服务（QPUUID.qp_service_uuid）
     * 5. 发现青萍服务下的特征（特征定义在 QPUUID中）
     * 6. 监听通知特征
     * 7. 设置token (调用的QPUUID.base_write_characteristic 对应的特征写，在base_notify_characteristic中监听设置结果 —— 04ff010000 为成功，其他为失败)
     * 注意： token 是随机生成的16字节，demo中为了演示写死了，发送的内容是 length + 命令 + token，其中 length 是 命令 + token的长度——即 1 + 16 = 17(用hex表示为0x11)
     * 8. 验证token （调用的QPUUID.base_write_characteristic 对应的特征写，在base_notify_characteristic中监听验证结果结果 —— 04ff020000 为成功，其他为失败）
     * 注意：这里待验证的token是第7步，设置的那个随机token
     * 9. 连接 Wi-Fi （调用的QPUUID.my_write_characteristic 对应的特征写，在my_notify_characteristic中监听连接结果， 020101 为 Wi-Fi 连接成功，其他为失败，注意有时候密码输入错误时，设备也有可能不返回错误码，所以在发送连接 Wi-Fi 命令时候最好设置一个 timer，timer 超时也被认为是连接 Wi-Fi 失败 ）
     */
    public func startScan() {
        print("开始扫描")
        //1. 开始扫描
        myCentralManager = CBCentralManager()
        //设置代理
        myCentralManager.delegate = self
    }
    
    public func stopScan() {
        print("停止扫描")
        self.myCentralManager.stopScan()
    }
    
    
    /**
     开始扫描
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BLE UPDATE:\(central.state.rawValue)")
        if central.state == .poweredOn {
            myCentralManager.scanForPeripherals(withServices: [QPUUID.QP_UUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //设备没有名称时，丢弃
        guard let _ =  peripheral.name else {return}
        guard let data = advertisementData[CBAdvertisementDataServiceDataKey] as? NSDictionary else {return}
        guard let fdcdData = data[QPUUID.QP_UUID] as? Data else {return}
        
        //解析广播，device 中有mac地址
        guard let device:QPDevice = Util.parsePeripherals(fdcdData) else {return}
        
        //2. 扫描到目标设备（解析后的isBind为true——即为绑定包，且 productId为 青萍空气检测仪 Lite）
        if device.productID == QPProductID.CGDN1 && device.isBind {
            peripheralDelegate.peripheral = peripheral
            currentDevice = device
            
            //找到目标设备后停止扫脚
            myCentralManager.stopScan()
            
            //3. 连接设备
            myCentralManager.connect(peripheral, options: nil)
        }
    }
    
    /**
     设备连接成功时回调
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.identifier == peripheralDelegate.peripheral.identifier {
            print("连接成功",currentDevice)
            peripheral.delegate = peripheralDelegate
            
            //4. 发现青萍服务（QPUUID.qp_service_uuid）
            peripheral.discoverServices([QPUUID.qp_service_uuid])
        }
    }
    
    /**
     设备连接失败时回调
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败：", peripheral, error)
    }
    
    /**
     断开与设备连接时回调
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("已断开连接：", peripheral, currentDevice)
    }
    
}
