//
//  ViewController.swift
//  JunVisionFace
//
//  Created by iOS_Tian on 2017/11/22.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var titleArr = ["文字识别", "矩形识别", "条码识别", "人脸特征识别", "静态人脸识别", "动态人脸识别", "实时动态添加"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Vision列表"
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell?.textLabel?.text = titleArr[indexPath.row]
            cell?.accessoryType = .disclosureIndicator
            cell?.selectionStyle = .none
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcs = [TextViewController(), RectangleViewController(), CodeViewController(), FeatureViewController(), StaticFaceViewController(), DynamicFaceViewController(), RealAddViewController()]
        let vc = vcs[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
