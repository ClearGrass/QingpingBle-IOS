//
//  Data-extension.swift
//  QingpingBleIOS
//
//  Created by 虎正玺 on 2022/9/1.
//

import Foundation


extension Data {
    var hexData: String  {
        map {String(format: "%02x", $0)}.joined()
    }
    func subdata(in range: ClosedRange<Index>) -> Data {
        return subdata(in: range.lowerBound ..< range.upperBound + 1)
    }
}
