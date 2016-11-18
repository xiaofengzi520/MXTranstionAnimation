//
//  MXNavigationViewController.swift
//  MXTranstionAnimation
//
//  Created by muxiao on 2016/11/17.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit

class MXNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
}
