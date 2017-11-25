//
//  CodeModel.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/25.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Vision

class CodeModel: NSObject {
    /// 条码类型
    var symbology: VNBarcodeSymbology?
    /// 条码数据
    var barcodeDescriptor: CIBarcodeDescriptor?
    /// 条码链接(一般是网址)
    var payloadStringValue: String?
    
    
    init(code: VNBarcodeObservation) {
        super.init()
        
        symbology = code.symbology
        barcodeDescriptor = code.barcodeDescriptor
        payloadStringValue = code.payloadStringValue
    }
}
