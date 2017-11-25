//
//  CodeViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/25.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class CodeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "条码识别"
    }
}

extension CodeViewController{
    override func startRecognitionAction(_ sender: Any) {
        super.startRecognitionAction(sender)
        
        guard let image = selectorImage else { return }
        visionTool.visionDetectImage(type: .code, image: image) { (rectArr, dataArr) in
            //1. 识别到的大区域
            if let rectArray = rectArr {
                for textRect in rectArray{
                    self.cleanView.addSubview(viewTool.addRectangleView(rect: textRect))
                }
            }
            
            //2. 识别到的条码信息
            guard let codeArr = dataArr as? [CodeModel] else { return }
            for code in codeArr{
                print(code.payloadStringValue ?? "")
                self.handleCodeInfo(code: code)
            }
        }
    }
    
    /// 处理条码信息
    fileprivate func handleCodeInfo(code: CodeModel){
        //1. 获取条码类型
        guard let type = code.symbology else { return }
        
        //2. 执行不同的操作
        switch type {
        case .QR:
            qrCodeHandle(barCode: code.barcodeDescriptor)
        default:
            break
        }
    }
    
    /// 二维码信息处理
    fileprivate func qrCodeHandle(barCode: CIBarcodeDescriptor?){
        //1. 转成对应的条码对象
        guard let code = barCode as? CIQRCodeDescriptor else { return }
        
        //2.
        let level = code.errorCorrectionLevel.hashValue
        let version = code.symbolVersion
        let mask = code.maskPattern
        print("这是二维码信息--", level, "---", version, "----", mask)
    }
}

/*
 public enum ErrorCorrectionLevel : Int {
 
 case levelL
 
 case levelM
 
 case levelQ
 
 case levelH
 }
 */
