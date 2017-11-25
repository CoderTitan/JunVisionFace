//
//  JunVisionTool.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/24.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Vision

enum JunVisionDetectType {
    case text
    case feature
    case rectangle
    case staticFace
    case hotFace
    case realAdd
}

class JunVisionTool: NSObject {
    typealias JunDetectHandle = ((_ bigRectArr: [CGRect]?, _ backArr: [Any]?) -> ())
    
}

extension JunVisionTool {
    /// 识别图片(根据不同类型)
    func visionDetectImage(type: JunVisionDetectType, image: UIImage, _ completeBack: @escaping JunDetectHandle){
        //1. 转成ciimage
        guard let ciImage = CIImage(image: image) else { return }
        
        //2. 创建处理request
        let requestHandle = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        //3. 创建baseRequest
        //大多数识别请求request都继承自VNImageBasedRequest
        var baseRequest = VNImageBasedRequest()
        
        //4. 设置回调
        let completionHandle: VNRequestCompletionHandler = { request, error in
            let observations = request.results
            self.handleImageObservable(type: type, image: image, observations, completeBack)
        }
        
        //5. 创建识别请求
        switch type {
        case .text:
            baseRequest = VNDetectTextRectanglesRequest(completionHandler: completionHandle)
            baseRequest.setValue(true, forKey: "reportCharacterBoxes") // 设置识别具体文字
        case .feature:
            baseRequest = VNDetectFaceLandmarksRequest(completionHandler: completionHandle)
        case .rectangle:
            baseRequest = VNDetectRectanglesRequest(completionHandler: completionHandle)
        case .staticFace:
            baseRequest = VNDetectFaceRectanglesRequest(completionHandler: completionHandle)
        default:
            break
        }
        
        //6. 发送请求
        try! requestHandle.perform([baseRequest])
    }
    
    /// 处理识别后的数据
    fileprivate func handleImageObservable(type: JunVisionDetectType, image: UIImage, _ observations: [Any]?, _ completionHandle: JunDetectHandle){
        switch type {
        case .text:
            textDectect(observations, image: image, completionHandle)
        case .feature:
            faceFeatureDectect(observations, image: image, completionHandle)
        case .rectangle:
            rectangleDectect(observations, image: image, completionHandle)
        case .staticFace:
            staticFaceDectect(observations, image: image, completionHandle)
        default:
            break
        }
    }
}

/*
 * continue: 结束当前循环, 继续执行下一次循环
 * break: 结束所有操作, 直接跳出循环
 * return: 必须在函数内使用, 直接结束该函数
 */
//MARK: 识别方式
extension JunVisionTool {
    /// 文字识别
    fileprivate func textDectect(_ observations: [Any]?, image: UIImage, _ complecHandle: JunDetectHandle){
        //1. 获取识别到的VNTextObservation
        guard let boxArr = observations as? [VNTextObservation] else { return }
        
        //2. 创建rect数组
        var bigRects = [CGRect](), smallRects = [CGRect]()
        
        //3. 遍历识别结果
        for boxObj in boxArr {
            // 3.1
            bigRects.append(convertRect(boxObj.boundingBox, image))
            //2. 获取
            guard let rectangleArr = boxObj.characterBoxes else { continue }
            for rectangle in rectangleArr{
                //3. 得到每一个对象的尺寸
                let boundBox = rectangle.boundingBox
                smallRects.append(convertRect(boundBox, image))
            }
        }
        
        //4. 回调结果
        complecHandle(bigRects, smallRects)
    }
    
    /// 特征识别
    fileprivate func faceFeatureDectect(_ observations: [Any]?, image: UIImage, _ complecHandle: JunDetectHandle){
        //1. 获取识别到的VNRectangleObservation
        guard let boxArr = observations as? [VNFaceObservation] else { return }
        
        //2. 创建存储数组
        var faceArr = [FaceFeatureModel]()
        
        //3. 遍历所有特征
        for feature in boxArr {
            guard let landmarks = feature.landmarks else { return }
            let faceFeature = FaceFeatureModel(face: landmarks)
            faceFeature.faceObservation = feature
            faceArr.append(faceFeature)
        }
        
        //4. 回调
        complecHandle([], faceArr)
    }
    
    /// 矩形检测
    fileprivate func rectangleDectect(_ observations: [Any]?, image: UIImage, _ complecHandle: JunDetectHandle){
        //1. 获取识别到的VNRectangleObservation
        guard let boxArr = observations as? [VNRectangleObservation] else { return }
        //2. 创建rect数组
        var bigRects = [CGRect]()
        //3. 遍历识别结果
        for boxObj in boxArr {
            // 3.1
            bigRects.append(convertRect(boxObj.boundingBox, image))
        }
        //4. 回调结果
        complecHandle(bigRects, [])
    }
    
    /// 静态人脸识别
    fileprivate func staticFaceDectect(_ observations: [Any]?, image: UIImage, _ complecHandle: JunDetectHandle){
        //1. 获取识别到的VNFaceObservation
        guard let boxArr = observations as? [VNFaceObservation] else { return }
        //2. 创建rect数组
        var bigRects = [CGRect]()
        //3. 遍历识别结果
        for boxObj in boxArr {
            // 3.1
            bigRects.append(convertRect(boxObj.boundingBox, image))
        }
        //4. 回调结果
        complecHandle(bigRects, [])
    }

}


//MARK: 坐标转换和添加红框
extension JunVisionTool{
    /// 坐标转换
    fileprivate func convertRect(_ rectangleRect: CGRect, _ image: UIImage) -> CGRect {
        let imageSize = image.scaleImage()
        let w = rectangleRect.width * imageSize.width
        let h = rectangleRect.height * imageSize.height
        let x = rectangleRect.minX * imageSize.width
        //该Y坐标与UIView的Y坐标是相反的
        let y = (1 - rectangleRect.minY) * imageSize.height - h
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    //runtime获取对象属性
    fileprivate func getAllKeys(anyClass: AnyClass, _ callBack: @escaping ((_ key: String?) -> ())) -> [String] {
        var keyArr = [String]()
        
        //1. runtime获取
        var count: UInt32 = 0
        
        //1.1 获取所有属性
        guard let propertyArr = class_copyPropertyList(anyClass.self, &count) else { return [] }
        
        //1.2 遍历所有属性
        for i in 0..<count {
            let property = propertyArr[Int(i)]
            
            //1.3获取属性名
            let keyStr = String(cString: property_getName(property))
            keyArr.append(keyStr)
            
            //1.4 回调
            callBack(keyStr)
        }
        
        return keyArr
    }
}
