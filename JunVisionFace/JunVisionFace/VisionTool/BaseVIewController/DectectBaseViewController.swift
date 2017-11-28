//
//  DectectBaseViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/27.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class DectectBaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    ///相册选择的图片
    var selectorImage: UIImage?
    var imageView = UIImageView()
    lazy var cleanView: UIView = {
        guard let imageSize = selectorImage?.scaleImage() else { return UIView() }
        let cleanVIew = UIView()
        cleanVIew.backgroundColor = UIColor.clear
        return cleanVIew
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVIews()
    }
    
    /// 创建界面
    func setupVIews(){
        view.backgroundColor = UIColor.white
        
        view.addSubview(addButton(title: "选择图片", rect: CGRect(x: 50, y: 74, width: kScreenWidth - 100, height: 30), action: #selector(selectedImageAction(_:))))
        view.addSubview(addButton(title: "开始识别", rect: CGRect(x: 50, y: kScreenHeight - 40, width: kScreenWidth - 100, height: 30), action: #selector(startRecognitionAction(_:))))
        
        imageView.frame = CGRect(x: 0, y: 120, width: kScreenWidth, height: kScreenWidth / 125 * 161)
        imageView.backgroundColor = UIColor.cyan
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        imageView.addSubview(cleanView)
    }
    
    
    //访问相册
    func useringPhotoLibrary(){
        //1. 判断是否允许该操作
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("操作限制, 不可执行")
            return
        }
        
        //2. 创建照片选择器
        let imagePC = UIImagePickerController()
        //2.1 设置数据源
        imagePC.sourceType = .photoLibrary
        //2.2 设置代理
        imagePC.delegate = self
        //2.3 的弹出控制器
        present(imagePC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 1. 获取选中的图片
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        selectorImage = image
        imageView.image = image
        
        //3. 退出控制器
        picker.dismiss(animated: true, completion: nil)
    }
    
    //选取完成后调用
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: 界面处理
extension DectectBaseViewController{
    fileprivate func addButton(title: String, rect: CGRect, action: Selector) -> UIButton{
        let button = UIButton(type: .custom)
        button.frame = rect
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    //选择图片
    @objc func selectedImageAction(_ sender: Any) {
        //0. 清除所有红框
        for subview in cleanView.subviews {
            subview.removeFromSuperview()
        }
        
        //1. 选择图片
        useringPhotoLibrary()
    }
    
    //开始识别
    @objc func startRecognitionAction(_ sender: Any) {
        //0. 清除所有红框
        for subview in cleanView.subviews {
            subview.removeFromSuperview()
        }
        
        //1. 获取尺寸一样的图片
        guard let image = selectorImage else { return }
        
        //2. 修改cleanView尺寸
        let imageSize = image.scaleImage()
        cleanView.frame = CGRect(x: (kScreenWidth - imageSize.width) / 2, y: (kScreenWidth / imageViewScale - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
    }
}
