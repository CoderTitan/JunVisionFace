//
//  DynamicFaceViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/23.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class DynamicFaceViewController: ScanBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "动态人脸识别"
    }
}

//处理扫描结果
extension DynamicFaceViewController{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //0. 清除所有红框
        for subView in cleanView.subviews {
            subView.removeFromSuperview()
        }
        
        //1. 获取CVPixelBuffer对象
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let input = self.deviceInput else { "获取设备失败".show(); return }
        
        //2. 获取扫描结果
        visionTool.visionScan(type: .hotFace, scanRect: previewLayer.bounds, pixelBuffer: cvBuffer) { (bigArr, smallArr) in
            //2.1. 识别到的大区域
            if let rectArray = bigArr {
                for textRect in rectArray{
                    DispatchQueue.main.async {
                        self.cleanView.addSubview(viewTool.addRectangleView(rect: textRect, input.device.position))
                    }
                }
            }
        }
        
    }
}
