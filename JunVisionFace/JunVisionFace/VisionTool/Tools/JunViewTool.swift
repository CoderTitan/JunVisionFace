//
//  JunViewTool.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/25.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class JunViewTool: NSObject {

}

extension JunViewTool{
    /// 添加红框view
    func addRectangleView(rect: CGRect, _ position: AVCaptureDevice.Position = .back) -> UIView {
        // 坐标是以后摄像头为标准的, 前摄像头在后摄像头的基础上翻转了180度
        let x = position == .back ? rect.minX : rect.width - rect.maxX
        let boxView = UIView(frame: CGRect(x: x, y: rect.minY, width: rect.width, height: rect.height))
        boxView.backgroundColor = UIColor.clear
        boxView.layer.borderColor = UIColor.red.cgColor
        boxView.layer.borderWidth = 2
        return boxView
    }
    
    
    /// 添加红框layer
    func addRectangleLayer(rect: CGRect) -> CALayer {
        let boxLayer = CALayer()
        boxLayer.frame = rect
        boxLayer.cornerRadius = 3
        boxLayer.borderColor = UIColor.red.cgColor
        boxLayer.borderWidth = 1.5
        return boxLayer
    }
    
    /// 添加眼睛imageView
    func addEyeImageView(rect: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: rect)
        imageView.image = UIImage(named: "eyes")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
