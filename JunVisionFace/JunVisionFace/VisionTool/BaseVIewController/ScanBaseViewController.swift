//
//  ScanBaseViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/27.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ScanBaseViewController: UIViewController {

    fileprivate var session = AVCaptureSession()
    fileprivate var videoOutput = AVCaptureVideoDataOutput()
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    var deviceInput: AVCaptureDeviceInput?
    //懒加载属性
    lazy var cleanView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        getAuthorization()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //停止扫描
        session.stopRunning()
        previewLayer.removeFromSuperlayer()
    }
}


//MARK: 设置界面
extension ScanBaseViewController{
    fileprivate func setupViews(){
        view.backgroundColor = UIColor.black
        
        //添加透明View
        view.addSubview(cleanView)
        
        let bottomView = UIView(frame: CGRect(x: 0, y: view.frame.height - 50, width: kScreenWidth, height: 50))
        bottomView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        cleanView.addSubview(bottomView)
        
        //切换摄像头
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "切换摄像", style: .plain, target: self, action: #selector(switchCameraAction))
    }
    
    //切换摄像头
    @objc fileprivate func switchCameraAction(){
        //1. 执行转场动画
        let anima = CATransition()
        anima.type = "oglFlip"
        anima.subtype = "fromLeft"
        anima.duration = 0.5
        view.layer.add(anima, forKey: nil)
        
        //2. 获取当前摄像头
        guard let deviceIn = deviceInput else { return }
        let position: AVCaptureDevice.Position = deviceIn.device.position == .back ? .front : .back
        
        //3. 创建新的input
        let deviceSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
        guard let newDevice = deviceSession.devices.filter({ $0.position == position }).first else { return }
        guard let newVideoInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
        
        //4. 移除旧输入，添加新输入
        //4.1 设备加锁
        session.beginConfiguration()
        //4.2. 移除旧设备
        session.removeInput(deviceIn)
        //4.3. 添加新设备
        session.addInput(newVideoInput)
        
        //4.4. 重新设置输出方向
        guard let connection = videoOutput.connection(with: .video) else { return }
        //6.2. 设置输出方向
        if connection.isVideoOrientationSupported{
            connection.videoOrientation = .portrait
        }
        //6.3. 视频稳定性设置
        if connection.isVideoStabilizationSupported{
            connection.preferredVideoStabilizationMode = .auto
        }
        
        //4.5. 设备解锁
        session.commitConfiguration()
        
        //5. 保存最新输入
        deviceInput = newVideoInput
    }
}


//MARK: 添加摄像头
extension ScanBaseViewController {
    //请求相机权限
    fileprivate func getAuthorization(){
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if videoStatus == .authorized || videoStatus == .notDetermined{
            addScaningVideo()
        }else{
            print("相机权限未开启")
        }
    }
    
    //添加摄像头
    fileprivate func addScaningVideo(){
        //1.获取输入设备（摄像头）
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        //2.根据输入设备创建输入对象
        guard let deviceIn = try? AVCaptureDeviceInput(device: device) else { return }
        deviceInput = deviceIn
        
        //3.设置代理监听输出对象输出的数据，在主线程中刷新
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        //4.设置输出质量(高像素输出)
        session.sessionPreset = .high
        
        //5.添加输入到会话
        if session.canAddInput(deviceInput!) {
            session.addInput(deviceInput!)
        }
        
        //6. 添加输出到会话
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            
            //6.1. 设置输出视频相关属性
            guard let connection = videoOutput.connection(with: .video) else { return }
            //6.2. 设置输出方向
            if connection.isVideoOrientationSupported{
                connection.videoOrientation = .portrait
            }
            //6.3. 视频稳定性设置
            if connection.isVideoStabilizationSupported{
                connection.preferredVideoStabilizationMode = .auto
            }
        }
        
        //7.创建预览图层
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        //8. 开始扫描
        if !session.isRunning {
            DispatchQueue.global().async {
                self.session.startRunning()
            }
        }
    }
}


extension ScanBaseViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
