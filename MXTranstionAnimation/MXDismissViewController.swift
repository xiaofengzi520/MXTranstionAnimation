//
//  MXDismissViewController.swift
//  MXTranstionAnimation
//
//  Created by muxiao on 2016/11/17.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit

class MXDismissViewController: UIViewController {

    public var transitionAnimation:MXModalBlixtTransitionAnimation?;
    
    private lazy var gesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(swipeTransition(sender:)))
        return gesture;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(gesture);
        transitionAnimation?.dismissPanGesture = gesture;
        // Do any additional setup after loading the view.
    }

    func swipeTransition(sender:UIPanGestureRecognizer)  {
        switch sender.state {
        case .began:
            print("开始拖动");
            let point = sender.translation(in: view);
            if point.y > 0 {
                
                self.dismiss(animated: true, completion: nil);
            }
            break;
        default:
            break;
        }
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
