//
//  TrackViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/28.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class TrackViewController: ScanBaseViewController {

    /// 处理与多个图像序列的请求
    fileprivate let sequenceHandle = VNSequenceRequestHandler()
    fileprivate let redView = viewTool.addRectangleView(rect: CGRect.zero)
    fileprivate var lastObservation: VNDetectedObjectObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "对象检测和跟踪"
        
        cleanView.removeFromSuperview()
        view.addSubview(redView)
        
        //重置操作
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "重置", style: .plain, target: self, action: #selector(resetAction))

        //添加点击手势
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTapped(_:))))
    }
    
    @objc fileprivate func resetAction(){
        lastObservation = nil
        redView.frame = .zero
    }
    
    @objc fileprivate func userTapped(_ tap: UITapGestureRecognizer){
        //1. 重新设置红框的位置
        redView.frame.size = CGSize(width: 80, height: 80)
        redView.center = tap.location(in: view)
        
        //2. 转换坐标
        let convertRect = visionTool.convertRect(viewRect: redView.frame, layerRect: previewLayer.frame)
        
        //3. 根据点击的位置获取新的对象
        let newObservation = VNDetectedObjectObservation(boundingBox: convertRect)
        lastObservation = newObservation
    }
}


extension TrackViewController{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //1. 获取CVPixelBuffer对象
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let lastObservation = self.lastObservation
        else { return }
        
        //2. 创建回调
        let completionHandle: VNRequestCompletionHandler = { request, error in
            let observations = request.results
            self.handleVisionRequestUpdate(observations: observations)
        }
        
        //2. 创建跟踪识别请求
        let trackRequest = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: completionHandle)
        //将精度设置为高
        trackRequest.trackingLevel = .accurate
        
        //3. 发送请求
        do{
            try sequenceHandle.perform([trackRequest], on: cvBuffer)
        }catch{
            print("Throws: \(error)")
        }
    }
    
    /// 创建
    fileprivate func handleVisionRequestUpdate(observations: [Any]?){
        DispatchQueue.main.async {
            //1. 获取一个实际的结果
            guard let newObservation = observations?.first as? VNDetectedObjectObservation else { return }
            
            //2. 重新赋值
            self.lastObservation = newObservation
            
            //3.更新UI之前检测
            guard newObservation.confidence >= 0.3 else {
                self.redView.frame = .zero
                return
            }
            
            //4. 坐标转换
            let newRect = newObservation.boundingBox
            let convertRect = visionTool.convertRect(newRect, self.previewLayer.frame)
            self.redView.frame = convertRect
        }
    }
}
