//
//  MXTabBarViewController.swift
//  MXTranstionAnimation
//
//  Created by muxiao on 2016/11/17.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit

enum MXSwipeDirection{
    case right, left
    
    public static func TransitionDirection(_ fromVCIndex:Int, toVCIndex:Int) -> MXSwipeDirection {
        if fromVCIndex > toVCIndex {
            return .right
        }else{
            return .left
        }
    }
}
class MXTabBarViewController: UITabBarController {
    
    
    private lazy var tabBarTransitionDelegate:MXTabBarTransitionDelegate = {
        let tabBarTransitionDelegate = MXTabBarTransitionDelegate();
        return tabBarTransitionDelegate;
    }();
    private lazy var gesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(swipeTransition(sender:)))
        return gesture;
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = tabBarTransitionDelegate;
//        view.addGestureRecognizer(gesture);
    }
    
    func swipeTransition(sender:UIPanGestureRecognizer)  {
        switch sender.state {
        case .began:
            print("开始拖动");
            let point = sender.translation(in: view);
            let swipeDirection:MXSwipeDirection
            if point.x < 0 {
                print("左滑")
                swipeDirection = .left;
            }else{
                print("右滑");
                swipeDirection = .right;
            }
            selectedViewController(swipeDirection);
            break;
        default:
            break;
        }
    }
    
  
    private func selectedViewController(_ inDirection:MXSwipeDirection){
        let index = selectedIndex;
        if index == 0 && inDirection == .left {
            selectedVCIndex(1);
        }else if index == 1 && inDirection == .right{
            selectedVCIndex(0);
        }
        
    }
    
    private func selectedVCIndex(_ index:Int){
        tabBarTransitionDelegate.needInteractiveTransitioning(true, gesture: gesture);
        selectedIndex = index;
    }
}

class MXTabBarTransitionDelegate: NSObject,UITabBarControllerDelegate {
    private var transitionAnimation: MXSlideTransitionAnimation
    override init() {
        transitionAnimation = MXSlideTransitionAnimation();
        super.init();
    }
    
    func needInteractiveTransitioning(_ need:Bool, gesture:UIGestureRecognizer){
        transitionAnimation.interacting = need;
        transitionAnimation.gestureRecognizer = gesture;
    }
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return transitionAnimation.interacting ? transitionAnimation.percentTransition : nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitionAnimation;
    }
    
}

public class MXSlideTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    public var transitionContext: UIViewControllerContextTransitioning?
    private var tabBarTransitionDirection: MXSwipeDirection = .right
    public var percentTransition: UIPercentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
    public var interacting: Bool = false
    public var interactivePrecent: CGFloat = 0.3

    
    public var gestureRecognizer: UIGestureRecognizer? {
        didSet {
            gestureRecognizer?.addTarget(self, action: #selector(interactiveTransition(_:)))
        }
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.3;
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        self.transitionContext = transitionContext
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let containView = transitionContext.containerView
        guard let tabBarController = fromVC?.tabBarController else { fatalError("No TabBarController.") }
        guard let fromVCIndex = tabBarController.viewControllers?.index(of: fromVC!)
            , let toVCIndex = tabBarController.viewControllers?.index(of: toVC!) else {
                fatalError("VC not in TabBarController.")
        }
        
        let fromVCStartOriginX: CGFloat = 0
        var fromVCEndOriginX: CGFloat = -UIScreen.main.bounds.width
        var toVCStartOriginX: CGFloat = UIScreen.main.bounds.width
        let toVCEndOriginX: CGFloat = 0
        
        tabBarTransitionDirection = MXSwipeDirection.TransitionDirection(fromVCIndex, toVCIndex: toVCIndex);
        
        if tabBarTransitionDirection == .right {
            swap(&fromVCEndOriginX, &toVCStartOriginX)
        }
        
        containView.addSubview(fromVC!.view)
        containView.addSubview(toVC!.view)
        
        fromVC?.view.frame.origin.x = fromVCStartOriginX
        toVC?.view.frame.origin.x = toVCStartOriginX
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            fromVC?.view.frame.origin.x = fromVCEndOriginX
            toVC?.view.frame.origin.x = toVCEndOriginX
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if !transitionContext.transitionWasCancelled && finished {
            }
        }
    }
    
    public func interactiveTransition(_ sender: UIPanGestureRecognizer) {
        
        guard let view = sender.view else { return }
        
        let offsetX = tabBarTransitionDirection == .right ? sender.translation(in: view).x : -sender.translation(in: view).x
        
        var percent = offsetX / view.bounds.size.width
        
        percent = min(1.0, max(0, percent))
        
        switch sender.state {
        case .began :
            percentTransition.startInteractiveTransition(transitionContext!)
            interacting = true
        case .changed :
            interacting = true
            percentTransition.update(percent)
        default :
            interacting = false
            if percent > interactivePrecent {
                percentTransition.completionSpeed = 1.0 - percentTransition.percentComplete
                percentTransition.finish()
                gestureRecognizer?.removeTarget(self, action: #selector(interactiveTransition(_:)))
            } else {
                percentTransition.cancel()
            }
        }

    }
    
}


