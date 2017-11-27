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
    
}
