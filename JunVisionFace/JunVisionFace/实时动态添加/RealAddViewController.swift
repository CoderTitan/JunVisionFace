//
//  RealAddViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/23.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class RealAddViewController: ScanBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "实时动态添加"
    }
}

//处理扫描结果
extension RealAddViewController {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //0. 清除所有红框
        for subView in cleanView.subviews {
            subView.removeFromSuperview()
        }
        
        //1. 获取CVPixelBuffer对象
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let input = self.deviceInput else { return }
        
        //2. 获取扫描结果
        visionTool.visionScan(type: .realAdd, scanRect: previewLayer.bounds, pixelBuffer: cvBuffer) { (bigArr, smallArr) in
            //2.1. 识别到的大区域
            if let faceArr = smallArr as? [FaceFeatureModel] {
                for facemodel in faceArr{
                    DispatchQueue.main.async {
                        // 获取转换后的坐标
                        let rect = self.getEyePoint(faceModel: facemodel, position: input.device.position)
                        self.cleanView.addSubview(viewTool.addEyeImageView(rect: rect))
                    }
                }
            }
        }
    }
}


//MARK: 眼睛的坐标
extension RealAddViewController{
    /// H偶去转换后的尺寸坐标
    fileprivate func getEyePoint(faceModel: FaceFeatureModel, position: AVCaptureDevice.Position) -> CGRect{
        //1. 获取左右眼
        guard let leftEye = faceModel.leftEye else { return CGRect.zero }
        guard let rightEye = faceModel.rightEye else { return CGRect.zero }

        //2. 位置数组
        let leftPoint = conventPoint(landmark: leftEye, faceRect: faceModel.faceObservation.boundingBox, position: position)
        let rightPoint = conventPoint(landmark: rightEye, faceRect: faceModel.faceObservation.boundingBox, position: position)

        //3. 排序
        let pointXs = (leftPoint.0 + rightPoint.0).sorted()
        let pointYs = (leftPoint.1 + rightPoint.1).sorted()
        
        //4. 添加眼睛
        let image = UIImage(named: "eyes")!
        let imageWidth = (pointXs.last ?? 0.0) - (pointXs.first ?? 0) + 40
        let imageHeight = image.size.height / image.size.width * imageWidth
        
        return CGRect(x: (pointXs.first ?? 0) - 20, y: (pointYs.first ?? 0) - 5, width: imageWidth, height: imageHeight)
    }
    
    /// 坐标转换
    fileprivate func conventPoint(landmark: VNFaceLandmarkRegion2D, faceRect: CGRect, position: AVCaptureDevice.Position) -> ([CGFloat], [CGFloat]){
        //1. 定义
        var XArray = [CGFloat](), YArray = [CGFloat]()
        let viewRect = previewLayer.frame
        
        //2. 遍历
        for i in 0..<landmark.pointCount {
            //2.1 获取当前位置并转化到合适尺寸
            let point = landmark.normalizedPoints[i]
            let rectWidth = viewRect.width * faceRect.width
            let rectHeight = viewRect.height * faceRect.height
            let rectY = viewRect.height - (point.y * rectHeight + faceRect.minY * viewRect.height)
            var rectX = point.x * rectWidth + faceRect.minX * viewRect.width
            if position == .front{
                rectX = viewRect.width + (point.x - 1) * rectWidth
            }
            XArray.append(rectX)
            YArray.append(rectY)
        }
        
        return (XArray, YArray)
    }
    
}
