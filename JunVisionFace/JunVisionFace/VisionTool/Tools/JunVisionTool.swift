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
    case code
    case rectangle
    case staticFace
    case feature
    case hotFace
    case realAdd
}

class JunVisionTool: NSObject {
    typealias JunDetectHandle = ((_ bigRectArr: [CGRect]?, _ backArr: [Any]?) -> ())
    
}

//MARK: 图片识别
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
            // 设置识别具体文字
            baseRequest.setValue(true, forKey: "reportCharacterBoxes")
        case .code:
            let request = VNDetectBarcodesRequest(completionHandler: completionHandle)
            request.symbologies = VNDetectBarcodesRequest.supportedSymbologies
            baseRequest = request //设置可识别的条码种类
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
        DispatchQueue.global().async {
            do{
                try requestHandle.perform([baseRequest])
            }catch{
                print("Throws：\(error)")
            }
        }
    }
    
    /// 处理识别后的数据
    fileprivate func handleImageObservable(type: JunVisionDetectType, image: UIImage, _ observations: [Any]?, _ completionHandle: JunDetectHandle){
        switch type {
        case .text:
            textDectect(observations, image: image, completionHandle)
        case .code:
            codeDectect(observations, image: image, completionHandle)
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


//MARK: 相机扫描
extension JunVisionTool{
    /// 相机扫描结果处理
    func visionScan(type: JunVisionDetectType, scanRect: CGRect, pixelBuffer: CVPixelBuffer, _ completionHandle: @escaping JunDetectHandle){
        //1. 创建处理请求
        let faceHandle = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        //2. 设置回调
        let completionHandle: VNRequestCompletionHandler = { request, error in
            let observations = request.results
            self.handleScanObservations(type: type, rect: scanRect, observations, completionHandle)
        }
        
        //3. 创建识别请求
        var baseRequest = VNImageBasedRequest()
        switch type {
        case .hotFace:
            baseRequest = VNDetectFaceRectanglesRequest(completionHandler: completionHandle)
        case .realAdd:
            baseRequest = VNDetectFaceLandmarksRequest(completionHandler: completionHandle)
        default:
            break
        }
        
        //4. 发送请求
        // 此处数据在不断地刷新, 必须在子线程执行,否则会堵塞主线程,导致app失去响应(亲自踩过的坑)
        DispatchQueue.global().async {
            do{
                try faceHandle.perform([baseRequest])
            }catch{
                print("Throws：\(error)")
            }
        }
    }
    
    /// 处理扫描后的数据
    fileprivate func handleScanObservations(type: JunVisionDetectType, rect: CGRect, _ observations: [Any]?, _ completionHandle: JunDetectHandle){
        switch type {
        case .hotFace:
            dynamicFaceScan(rect, observations, completionHandle)
        case .realAdd:
            addFaceScan(rect, observations, completionHandle)
        default:
            break
        }
    }
}


//MARK: 图像扫描方式
extension JunVisionTool {
    /// 动态人脸识别
    fileprivate func dynamicFaceScan(_ rect: CGRect, _ observations: [Any]?, _ complecHandle: JunDetectHandle){
        //1. 获取识别到的VNFaceObservation
        guard let boxArr = observations as? [VNFaceObservation] else { return }
        //2. 创建rect数组
        var bigRects = [CGRect](), faceArr = [FaceFeatureModel]()
        //3. 遍历识别结果
        for boxObj in boxArr {
            // 3.1 获取识别到的位置
            bigRects.append(convertRect(boxObj.boundingBox, rect))
        }
        //4. 回调结果
        complecHandle(bigRects, faceArr)
    }
    
    /// 实时动态添加
    fileprivate func addFaceScan(_ rect: CGRect, _ observations: [Any]?, _ complecHandle: JunDetectHandle){
        //1. 获取识别到的VNFaceObservation
        guard let boxArr = observations as? [VNFaceObservation] else { return }
        //2. 创建rect数组
        var faceArr = [FaceFeatureModel]()
        //3. 遍历识别结果
        for feature in boxArr {
            guard let landmarks = feature.landmarks else { return }
            let faceFeature = FaceFeatureModel(face: landmarks)
            faceFeature.faceObservation = feature
            faceArr.append(faceFeature)
        }
        //4. 回调结果
        complecHandle([], faceArr)
    }
}


//MARK: 图片识别方式
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
    
    /// 条码识别
    fileprivate func codeDectect(_ observations: [Any]?, image: UIImage, _ complecHandle: JunDetectHandle){
        //1. 获取识别到的VNRectangleObservation
        guard let boxArr = observations as? [VNBarcodeObservation] else { return }
        //2. 创建rect数组
        var bigRects = [CGRect](), codeArr = [CodeModel]()
        //3. 遍历识别结果
        for boxObj in boxArr {
            // 3.1 获取识别到的位置
            bigRects.append(convertRect(boxObj.boundingBox, image))
            
            //3.2 获取每一个条码的信息
            codeArr.append(CodeModel(code: boxObj))
        }
        //4. 回调结果
        complecHandle(bigRects, codeArr)

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
    /// image坐标转换
    fileprivate func convertRect(_ rectangleRect: CGRect, _ image: UIImage) -> CGRect {
        let imageSize = image.scaleImage()
        let w = rectangleRect.width * imageSize.width
        let h = rectangleRect.height * imageSize.height
        let x = rectangleRect.minX * imageSize.width
        //该Y坐标与UIView的Y坐标是相反的
        let y = (1 - rectangleRect.minY) * imageSize.height - h
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    /// rect坐标转换
    func convertRect(_ rectangleRect: CGRect, _ rect: CGRect) -> CGRect {
        let size = rect.size
        let w = rectangleRect.width * size.width
        let h = rectangleRect.height * size.height
        let x = rectangleRect.minX * size.width
        //该Y坐标与UIView的Y坐标是相反的
        let y = (1 - rectangleRect.maxY) * size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    /// 正常坐标转成layer坐标
    func convertRect(viewRect: CGRect, layerRect: CGRect) -> CGRect{
        let size = layerRect.size
        let w = viewRect.width / size.width
        let h = viewRect.height / size.height
        let x = viewRect.minX / size.width
        let y = 1 - viewRect.maxY / size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
}



/*
 * continue: 结束当前循环, 继续执行下一次循环
 * break: 结束所有操作, 直接跳出循环
 * return: 必须在函数内使用, 直接结束该函数
 */

