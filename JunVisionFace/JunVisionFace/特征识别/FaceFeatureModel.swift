//
//  FaceFeatureModel.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/25.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Vision

class FaceFeatureModel: NSObject {
    /// 脸部轮廓
    var faceContour: VNFaceLandmarkRegion2D?
    
    /// 左眼, 右眼
    var leftEye: VNFaceLandmarkRegion2D?
    var rightEye: VNFaceLandmarkRegion2D?
    
    /// 左睫毛, 右睫毛
    var leftEyebrow: VNFaceLandmarkRegion2D?
    var rightEyebrow: VNFaceLandmarkRegion2D?
    
    /// 左眼瞳, 右眼瞳
    var leftPupil: VNFaceLandmarkRegion2D?
    var rightPupil: VNFaceLandmarkRegion2D?
    
    /// 鼻子, 鼻嵴, 正中线
    var nose: VNFaceLandmarkRegion2D?
    var noseCrest: VNFaceLandmarkRegion2D?
    var medianLine: VNFaceLandmarkRegion2D?
    
    /// 外唇, 内唇
    var outerLips: VNFaceLandmarkRegion2D?
    var innerLips: VNFaceLandmarkRegion2D?

    /// 所有属性数组
    var landmarkArr = [VNFaceLandmarkRegion2D?]()
    
    /// face对象
    var faceObservation = VNFaceObservation()
    
    
    
    /// 初始化方法
    init(face: VNFaceLandmarks2D) {
        super.init()
        
        faceContour = face.faceContour
        
        leftEye = face.leftEye
        rightEye = face.rightEye
        
        leftEyebrow = face.leftEyebrow
        rightEyebrow = face.rightEyebrow
        
        leftPupil = face.leftPupil
        rightPupil = face.rightPupil
        
        nose = face.nose
        noseCrest = face.noseCrest
        medianLine = face.medianLine
        
        outerLips = face.outerLips
        innerLips = face.innerLips
        
        //添加到数组中
        landmarkArr.append(faceContour)
        
        landmarkArr.append(leftEye)
        landmarkArr.append(rightEye)
        
        landmarkArr.append(leftEyebrow)
        landmarkArr.append(rightEyebrow)
        
        landmarkArr.append(leftPupil)
        landmarkArr.append(rightPupil)
        
        landmarkArr.append(nose)
        landmarkArr.append(noseCrest)
        landmarkArr.append(medianLine)

        landmarkArr.append(outerLips)
        landmarkArr.append(innerLips)
    }
}

