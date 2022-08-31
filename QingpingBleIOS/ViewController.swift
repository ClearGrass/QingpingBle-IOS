//
//  ViewController.swift
//  QingpingBleIOS
//
//  Created by Tiger on 2022/8/30.
//

import UIKit
import SnapKit
import CoreBluetooth
import RxSwift


class ViewController: UIViewController {
    
    var centrolManagerDelegate: QPCentralManagerDelegate!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        centrolManagerDelegate = QPCentralManagerDelegate()
        
        initViews()
        
    }
    
    private func initViews() {
        
        let btnStartScanning = UIButton()
        view.addSubview(btnStartScanning)
        btnStartScanning.setTitle("扫描并连接", for: .normal)
        btnStartScanning.backgroundColor = UIColor.orange
        btnStartScanning.addTarget(self, action: #selector(startBleScanning), for: .touchUpInside)
        btnStartScanning.snp.makeConstraints{ (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(44)
            make.center.equalTo(view)
        }
        
        let btnStopScanning = UIButton()
        view.addSubview(btnStopScanning)
        btnStopScanning.setTitle("停止扫描", for: .normal)
        btnStopScanning.backgroundColor = UIColor.orange
        btnStopScanning.addTarget(self, action: #selector(stopScanning), for: .touchUpInside)
        btnStopScanning.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(44)
            make.top.equalTo(btnStartScanning.snp.bottom).offset(20)
            make.centerX.equalTo(btnStartScanning)
        }
        
    }
    
    @objc func startBleScanning() {
        centrolManagerDelegate.startScan()
    }
    
    
    @objc func stopScanning() {
        centrolManagerDelegate.stopScan()
    }
    
}

