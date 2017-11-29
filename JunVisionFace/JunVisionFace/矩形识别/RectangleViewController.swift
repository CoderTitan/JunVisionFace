//
//  RectangleViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/23.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class RectangleViewController: DectectBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "矩形识别"
    }

}

extension RectangleViewController{
    //开始识别
    @objc override func startRecognitionAction(_ sender: Any) {
        super.startRecognitionAction(sender)
        
        guard let image = selectorImage else { return }
        visionTool.visionDetectImage(type: .rectangle, image: image) { (bigRects, smallRects)  in
            //2. 识别到的大区域
            guard let rectArr = bigRects else { return }
            for textRect in rectArr{
                DispatchQueue.main.async {   
                    self.cleanView.addSubview(viewTool.addRectangleView(rect: textRect))
                }
            }
        }
    }
}
