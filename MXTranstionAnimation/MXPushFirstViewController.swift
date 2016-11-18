//
//  MXPushFirstViewController.swift
//  MXTranstionAnimation
//
//  Created by muxiao on 2016/11/17.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit

class MXPushFirstViewController: UIViewController {
    
    var pushTransition:MXNavgationTransitionDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        pushTransition = MXNavgationTransitionDelegate();
        self.navigationController?.delegate = pushTransition;
    }
}


enum MXNavigationTransitionStatus{
    case push, pop
}

class MXNavgationTransitionDelegate: NSObject, UINavigationControllerDelegate {
    
    private let transitionAnimation:MXNavgationBlixtTransitionAnimation;
    private var navigationController:UINavigationController?;
    override init() {
        self.transitionAnimation = MXNavgationBlixtTransitionAnimation();
        super.init();
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return transitionAnimation.interacting ? transitionAnimation.percentTransition : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            transitionAnimation.transitionStatus = .push;
            break;
        case .pop:
            transitionAnimation.transitionStatus = .pop;
        default:
            return nil;
        }
        if self.navigationController == nil {
            self.navigationController = navigationController;
            navigationController.view.addGestureRecognizer(edgePanGestureRecognizer);
        }
        return transitionAnimation;
    }
    
    lazy var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePan(_:)))
        edgePanGestureRecognizer.edges = .left
        return edgePanGestureRecognizer
    }()
    
    public func edgePan(_ recognizer: UIPanGestureRecognizer) {
        
     
        guard let view = navigationController?.view else {
            return
        }
        var percent = recognizer.translation(in: view).x / view.bounds.size.width
        percent = min(1.0, max(0, percent))
        
        switch recognizer.state {
        case .began :
            guard (navigationController?.viewControllers.count)! > 1 else {
                return
            }
            transitionAnimation.interacting = true
            transitionAnimation.percentTransition = UIPercentDrivenInteractiveTransition()
            transitionAnimation.percentTransition?.startInteractiveTransition(transitionAnimation.transitionContext!)
            navigationController!.popViewController(animated: true)
        case .changed :
            transitionAnimation.percentTransition?.update(percent)
        default :
            transitionAnimation.interacting = false
            transitionAnimation.percentTransition?.completionSpeed = 1.0 - transitionAnimation.percentTransition!.percentComplete
            transitionAnimation.percentTransition?.finish()
            transitionAnimation.percentTransition = nil
        }
    }


}

class MXNavgationBlixtTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
  
    public var transitionStatus: MXNavigationTransitionStatus = .push;
    
    public var transitionContext: UIViewControllerContextTransitioning?
    
    public var percentTransition: UIPercentDrivenInteractiveTransition?
    public var interactivePrecent: CGFloat = 0.5

    
    public var interacting: Bool = false
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
 
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        self.transitionContext = transitionContext
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let containView = transitionContext.containerView
        let originX: CGFloat = 0
        fromVC?.view.layer.frame.origin.x = originX
        toVC?.view.layer.frame.origin.x = originX
        containView.addSubview(toVC!.view)
        containView.addSubview(fromVC!.view)
        let animationOptions:UIViewAnimationOptions = transitionStatus == .push ? .transitionFlipFromRight : .transitionFlipFromLeft;
        UIView.transition(from: fromVC!.view, to: toVC!.view, duration: transitionDuration(using: transitionContext), options: animationOptions, completion: {
            finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

        });
    }
    
}



