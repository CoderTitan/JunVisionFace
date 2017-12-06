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
        
        return CGSize(width: imageWidth, height: imageHeight)
    }
}


//MARK: String
extension String {
    public func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        if self.isEmpty { return }
        
        for view in window.subviews where view.tag == 33 {
            view.removeFromSuperview()
        }
        let blackView = UIView()
        blackView.backgroundColor = UIColor.black
        blackView.layer.cornerRadius = 2
        blackView.layer.masksToBounds = true
        blackView.tag = 33
        window.addSubview(blackView)
        
        let textLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 0, height: 0))
        textLabel.text = self
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.backgroundColor = UIColor.clear
        textLabel.font = UIFont.systemFont(ofSize: 14)
        blackView.addSubview(textLabel)
        
        let size = (self as NSString).boundingRect(with: CGSize(width: kScreenWidth / 3 * 2, height: CGFloat(HUGE)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 14)], context: nil).size
        textLabel.frame = CGRect(x: 10, y: 5, width: size.width, height: size.height)
        blackView.frame = CGRect(x: (kScreenWidth - textLabel.frame.width - 20) / 2, y: (kScreenHeight - textLabel.frame.height - 10) / 2, width: textLabel.frame.width + 20, height: textLabel.frame.height + 10)
        
        UIView.animate(withDuration: 0.5, delay: 3, options: .curveLinear, animations: {
            blackView.alpha = 0
        }) { (finished) in
            blackView.removeFromSuperview()
        }
    }
}
