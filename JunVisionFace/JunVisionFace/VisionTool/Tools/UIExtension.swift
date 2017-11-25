//
//  UIExtension.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/23.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Foundation
import Vision

//MARK: 全局属性
/// 全局图像识别工具类
let visionTool = JunVisionTool()
/// 全局视图处理类
let viewTool = JunViewTool()
/// 屏幕的宽
let kScreenWidth = UIScreen.main.bounds.size.width
/// 屏幕的高
let kScreenHeight = UIScreen.main.bounds.size.height
/// 显示图片的imageView的宽高比
let imageViewScale: CGFloat = 125 / 161




//MARK: UIImage
extension UIImage{
    /// 图片压缩到指定大小
    public func scaleImage() -> CGSize {
        //1. 图片的宽高比
        let imageScale = size.width / size.height
        var imageWidth: CGFloat = 1
        var imageHeight: CGFloat = 1
        if imageScale >= imageViewScale {
            imageWidth = kScreenWidth
            imageHeight = imageWidth / imageScale
        }else{
            imageHeight = kScreenWidth / imageViewScale
            imageWidth = imageHeight * imageScale
        }
        
        /*
        //2.1 开启图形上下文
        UIGraphicsBeginImageContext(CGSize(width: imageWidth, height: imageHeight))
        //2.2 绘制到图形上下文中
        draw(in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        //2.3 从上下文中获取图片
        guard let getImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        //2.4 关闭图形上下文
        UIGraphicsEndImageContext()
        //2.5 压缩图片
        guard let tempData = UIImageJPEGRepresentation(getImage, 0.5) else { return nil }
        return UIImage(data: tempData)
 */
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    
}


//MARK: UIView

