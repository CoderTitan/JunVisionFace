//
//  CodeViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/25.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class CodeViewController: DectectBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "条码识别"
    }
}

extension CodeViewController{
    override func startRecognitionAction(_ sender: Any) {
        super.startRecognitionAction(sender)
        
        guard let image = selectorImage else { "未获取到图片".show(); return }
        
        visionTool.visionDetectImage(type: .code, image: image) { (rectArr, dataArr) in
            DispatchQueue.main.async {
                //1. 识别到的大区域
                guard let rectArray = rectArr else { "未识别到条码".show(); return }
                for textRect in rectArray{
                    self.cleanView.addSubview(viewTool.addRectangleView(rect: textRect))
                }
                
                //2. 识别到的条码信息
                guard let codeArr = dataArr as? [CodeModel] else { "未识别到条码信息".show(); return }
                for code in codeArr{
                    print(code.payloadStringValue ?? "")
                    self.handleCodeInfo(code: code)
                }
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
        
        //2. 解读条码信息
        let level = code.errorCorrectionLevel.hashValue
        let version = code.symbolVersion
        let mask = code.maskPattern
        let data = code.errorCorrectedPayload
        let dataStr = String(data: data, encoding: .utf8)
        print("这是二维码信息--", level, "---", version, "----", mask, "---", dataStr ?? "")
    }
}

/* 纠错等级
 public enum ErrorCorrectionLevel : Int {
 
 case levelL
 
 case levelM
 
 case levelQ
 
 case levelH
 }
 */
