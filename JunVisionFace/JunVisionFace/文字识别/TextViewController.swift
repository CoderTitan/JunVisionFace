//
//  TextViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/23.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class TextViewController: DectectBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "文字识别"
    }
    
    //选择图片
    //开始识别
    @objc override func startRecognitionAction(_ sender: Any) {
        super.startRecognitionAction(sender)
        
        guard let image = selectorImage else { return }
        visionTool.visionDetectImage(type: .text, image: image) { (bigRects, smallRects)  in
            //2. 识别到的大区域(暂不显示)
//            guard let rectArr = bigRects else { return }
//            for textRect in rectArr{
//                self.cleanView.addSubview(visionTool.addRectangleView(rect: textRect))
//            }
            
            //3. 识别到的小区域
            guard let smallArr = smallRects as? [CGRect] else { return }
            for textRect in smallArr{
                DispatchQueue.main.async {   
                    self.cleanView.addSubview(viewTool.addRectangleView(rect: textRect))
                }
            }
        }

    }
}
