//
//  QPPeripheralDelegate.swift
//  QingpingBleIOS
//
//  Created by Tiger on 2022/8/31.
//

import Foundation
import CoreBluetooth

class QPPeripheralDelegate: NSObject, CBPeripheralDelegate {
    var peripheral:CBPeripheral!
    var baseWrite:CBCharacteristic?
    var myWrite:CBCharacteristic?
    
    //每包发送的最大字节数
    let MAX_BUFFER_SIZE = 20
    //
    var didUpdateNotificationStateForCharacteristics:[CBUUID] = []
    
    /**
     服务发现成功后回调
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error  == nil && peripheral.services?.count ?? 0 > 0 else {
            print("发现服务失败", error)
            return
        }
    
        print("发现服务成功，开始发现特征")
        
        //5. 发现青萍服务下的特征（特征定义在 QPUUID中）
        peripheral.services?.forEach({ service in
            peripheral.discoverCharacteristics([
                QPUUID.base_notify_characteristic,
                QPUUID.base_write_characteristic,
                QPUUID.my_notify_characteristic,
                QPUUID.my_write_characteristic
            ], for: service)
        })
        
    }
    
    /**
     发现特征成功后回调
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil  else {
            print("发现特征失败")
            return
        }
        print("发现特征成功", service.characteristics?.count)
        
        service.characteristics?.forEach({ characteristic in
            
            //6. 监听通知特征
            if characteristic.properties.contains(.notify) {
                print("为[\(characteristic.uuid.uuidString)]开启特征通知：")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.uuid.uuidString == QPUUID.base_write_characteristic.uuidString {
                baseWrite = characteristic
            }
            
            if characteristic.uuid.uuidString == QPUUID.my_write_characteristic.uuidString {
                myWrite = characteristic
            }
        })
    }
    
    /**
     特征变化通知设置成功后回调
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateFor：", characteristic.uuid.uuidString, characteristic.value?.hexData)
        didUpdateNotificationStateForCharacteristics.append(characteristic.uuid)
        
        //7. 设置token (调用的QPUUID.base_write_characteristic 对应的特征写，在base_notify_characteristic中监听设置结果 —— 04ff010000 为成功，其他为失败)
        if didUpdateNotificationStateForCharacteristics.count == 2 {
            setToken()
        }
    }
    
    /**
     特征value变化通知，
     设置token、验证token、连接 Wi-Fi 结果都会从这个方法回调
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let result = characteristic.value?.hexData ?? ""
        print("didUpdateValueFor:", characteristic.uuid.uuidString,  characteristic.value?.hexData)
        
        //设置token成功
        if result.starts(with: "04ff0100") {
            print("设置token成功")
            verifyToken()
        }else if result.starts(with: "04ff020000") { //验证token成功
            print("验证token成功")
            setWiFi("Xiaomi_DC9F", "sdjm_yfqb")
        }else if result.starts(with: "020101") {
            print("连接成功")
        }
        
    }
    
    /**
     调用 QPUUID.base_write_characteristic、 QPUUID.my_write_characteristic 对应的服务向设备写数据成功后回调
     注意：这里回调成功只代表数据发送到设备成功了，并不带表对应命令的执行结果，
     调用peripheral.writeValue方法时，type写.withResponse时才会有回调
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            print("didWriteValueFor：", characteristic.uuid.uuidString)
        }
        
    }
    
    
    /**
     7. 设置token (调用的QPUUID.base_write_characteristic 对应的特征写，在base_notify_characteristic中监听设置结果 —— 04ff010000 为成功，其他为失败)
     */
    private func setToken() {
        guard baseWrite != nil else {return }
        
        //这里延迟500毫秒的意义是 等待设置通知结束
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            let token = "1101c3755cec45fcccb52000ee4610c8b1a6"
            self.peripheral.writeValue(token.hexadecimal, for: self.baseWrite!, type: .withResponse)
            
        }
        
        
    }
    
    /**
     8. 验证token （调用的QPUUID.base_write_characteristic 对应的特征写，在base_notify_characteristic中监听验证结果结果 —— 04ff020000 为成功，其他为失败）
     */
    private func verifyToken() {
        guard baseWrite != nil else  {return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            let token = "1102c3755cec45fcccb52000ee4610c8b1a6"
            self.peripheral.writeValue(token.hexadecimal, for: self.baseWrite!, type: .withResponse)
        }
        
    }
    
    /**
     9. 连接 Wi-Fi （调用的QPUUID.my_write_characteristic 对应的特征写，在my_notify_characteristic中监听连接结果， 020101 为 Wi-Fi 连接成功，其他为失败，注意有时候密码输入错误时，设备也有可能不返回错误码，所以在发送连接 Wi-Fi 命令时候最好设置一个 timer，timer 超时也被认为是连接 Wi-Fi 失败 ）
     */
    private func setWiFi(_ ssid: String,_ passwod: String) {
        guard myWrite != nil else {return }
        //wifi信息的末班是 “ssid","password”,注意ssid和密码都需要用引号包起来
        let wifiInfo = "\"\(ssid)\",\"\(passwod)\""
        //转换成 Data
        var wifiInfoData = Data(wifiInfo.utf8)
        //在开始位置插入设置WiFi的命令[0x01]
        wifiInfoData.insert(1, at: 0)
        //在开始位置插入数据长度 length
        wifiInfoData.insert(Data.Element(wifiInfoData.count), at: 0)
        
        
        var curIndex = 0
        let dataCount = wifiInfoData.count
        
        //BLE 发送单包数据不超过20字节，所以需要拆包发送
        while curIndex < dataCount {
            let endIndex = curIndex + MAX_BUFFER_SIZE > dataCount ? dataCount : curIndex + MAX_BUFFER_SIZE
            print("发送数据到[\(myWrite?.uuid.uuidString)]:",wifiInfoData.subdata(in: curIndex..<endIndex).hexData)
            peripheral.writeValue( wifiInfoData.subdata(in: curIndex..<endIndex) , for: self.myWrite!, type: .withResponse)
            curIndex = curIndex + MAX_BUFFER_SIZE
            //延迟100毫秒
            usleep(100000)
        }
        
    }
}
