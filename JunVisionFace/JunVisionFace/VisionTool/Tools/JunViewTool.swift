//
//  JunViewTool.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/25.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Vision

class JunViewTool: NSObject {

}

extension JunViewTool{
    /// 添加红框
    func addRectangleView(rect: CGRect) -> UIView {
        let boxView = UIView(frame: rect)
        boxView.backgroundColor = UIColor.clear
        boxView.layer.borderColor = UIColor.red.cgColor
        boxView.layer.borderWidth = 2
        return boxView
    }
    
    /// 返回识别后的人脸特征图片
    func drawImage(image: UIImage, faceModel: FaceFeatureModel) -> UIImage {
        //1. 获取当前图片和face对象
        var sourceImage = image
        let faceObser = faceModel.faceObservation
        
        //2. 获取转换后的图片尺寸
        let imageSize = image.scaleImage()
        
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
                let rectWidth = imageSize.width * faceRect.width
                let rectHeight = imageSize.height * faceRect.height
                let tempPoint = CGPoint(x: point.x * rectWidth + faceRect.minX * imageSize.width, y: point.y * rectHeight + faceRect.minY * imageSize.height)
                pointArr.append(tempPoint)
            }
            
            //5. 开启图形上下文
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 1)
            
            //5.1 获取当前上下文
            let content = UIGraphicsGetCurrentContext()
            
            //5.2 设置填充颜色(setStroke设置描边颜色)
            UIColor.red.set()
            
            //5.3 设置宽度
            content?.setLineWidth(2)
            
            //5.4. 设置翻转
            content?.translateBy(x: 0, y: imageSize.height)
            content?.scaleBy(x: 1, y: -1)
            
            //5.5. 设置线的类型
            content?.setLineJoin(.round)
            content?.setLineCap(.round)
            
            //5.6. 设置抗锯齿
            content?.setShouldAntialias(true)
            content?.setAllowsAntialiasing(true)
            
            //5.7 开始绘制图片
//            content?.draw(<#T##layer: CGLayer##CGLayer#>, in: <#T##CGRect#>)
            content?.draw(sourceImage.cgImage!, in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            content?.addLines(between: pointArr)
            content?.drawPath(using: .stroke)
            
            //5.8 结束绘制
            sourceImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }

        return sourceImage
    }
}
