//
//  FaceFeatureView.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/25.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class FaceFeatureView: UIView {
    var faceModel: FaceFeatureModel!
    
    init(frame: CGRect, faceModel: FaceFeatureModel) {
        super.init(frame: frame)
        
        self.faceModel = faceModel
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //1. 获取当前图片和face对象
        let faceObser = faceModel.faceObservation
        
        //3. 获取脸部尺寸
        let faceRect = faceObser.boundingBox
        
        //4. 遍历所有特征
        for landmark in faceModel.landmarkArr{
            // 4.1 获取VNFaceLandmarkRegion2D对象
            guard let landmark2D = landmark else { continue }
            
            //4.2 遍历所有的像素点的坐标
            var pointArr = [CGPoint]()
            for i in 0..<landmark2D.pointCount {
                //4.3 获取当前位置并转化到合适尺寸
                let point = landmark2D.normalizedPoints[i]
                let rectWidth = frame.width * faceRect.width
                let rectHeight = frame.height * faceRect.height
                
                let tempPoint = CGPoint(x: point.x * rectWidth + faceRect.minX * frame.width, y: point.y * rectHeight + faceRect.minY * frame.height)
                pointArr.append(tempPoint)
            }
            
            //5.1 获取当前上下文
            let content = UIGraphicsGetCurrentContext()
            
            //5.2 设置填充颜色(setStroke设置描边颜色)
            UIColor.red.set()
            
            //5.3 设置宽度
            content?.setLineWidth(2)
            
            //5.4. 设置翻转
            content?.translateBy(x: 0, y: frame.height)
            content?.scaleBy(x: 1.0, y: -1.0)
            
            //5.5. 设置线的类型(连接处)
            content?.setLineJoin(.round)
            content?.setLineCap(.round)
            
            //5.6. 设置抗锯齿
            content?.setShouldAntialias(true)
            content?.setAllowsAntialiasing(true)
            
            //5.7 开始绘制
            content?.addLines(between: pointArr)
            content?.drawPath(using: .stroke)
            
            //5.8 结束绘制
            content?.strokePath()
        }

        
    }
}
