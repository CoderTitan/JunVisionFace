//
//  FeatureViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/23.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Vision

class FeatureViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "人脸特征识别"
    }
    
    override func startRecognitionAction(_ sender: Any) {
        super.startRecognitionAction(sender)
        
        guard let image = selectorImage else { return }
        visionTool.visionDetectImage(type: .feature, image: image) { (bigRects, smallRects)  in
            //1. 获取识别结果
            guard let faceArr = smallRects as? [FaceFeatureModel] else { return }
            
            //2. 遍历识别的人脸
            for feature in faceArr{
                let view = FaceFeatureView(frame: CGRect(x: 0, y: 0, width: self.cleanView.frame.width, height: self.cleanView.frame.height), faceModel: feature)
                self.cleanView.addSubview(view)
            }
        }
    }
}
