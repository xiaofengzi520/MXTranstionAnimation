//
//  MXPresentViewController.swift
//  MXTranstionAnimation
//
//  Created by muxiao on 2016/11/17.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit

class MXPresentViewController: UIViewController {
    var modalTransition:MXModalTransitionDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransition = MXModalTransitionDelegate();

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func present(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let modal = storyboard.instantiateViewController(withIdentifier: "MXDismissViewController") as! MXDismissViewController;
        modal.transitioningDelegate = modalTransition;
        modal.transitionAnimation = modalTransition.transitionAnimation;
        present(modal, animated: true, completion: nil);
    }
    override func viewWillDisappear(_ animated: Bool) {
    }

}

enum MXModalTransition {
    case present, dismiss
}

class MXModalTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
     let transitionAnimation:MXModalBlixtTransitionAnimation;
    private var navigationController:UINavigationController?;
    private var modalTransitionDelegate:MXModalTransitionDelegate!;
    override init() {
        self.transitionAnimation = MXModalBlixtTransitionAnimation();
        super.init();
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        transitionAnimation.transitionStatus = .present;
        
        return transitionAnimation;
    }
    
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        transitionAnimation.transitionStatus = .dismiss;
        return transitionAnimation;

    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        return transitionAnimation.interacting ? transitionAnimation.percentTransition : nil
    }
    
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        return transitionAnimation.interacting ? transitionAnimation.percentTransition : nil

    }

    
}

class MXModalBlixtTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    public var transitionStatus: MXModalTransition = .present;
    
    public var transitionContext: UIViewControllerContextTransitioning?
    
    public var percentTransition: UIPercentDrivenInteractiveTransition?
    public var interactivePrecent: CGFloat = 0.5
    
    public var dismissPanGesture: UIPanGestureRecognizer? = nil{
        didSet{
            dismissPanGesture?.addTarget(self, action: #selector(slideTransition(_:)))
        }
    }

    public func slideTransition(_ sender: UIPanGestureRecognizer) {
        
        
        let view = sender.view;
        
        let offsetY: CGFloat = transitionStatus == .dismiss ? sender.translation(in: view).y : -sender.translation(in: view).y
        
        var percent = offsetY / (view?.bounds.size.height)!
        
        percent = min(1.0, max(0, percent))
        
        percentTransition = percentTransition ?? {
            let percentTransition = UIPercentDrivenInteractiveTransition()
            percentTransition.startInteractiveTransition(transitionContext!)
            return percentTransition
            }()
        
        switch sender.state {
        case .began :
            interacting = true
        case .changed :
            interacting = true
            percentTransition?.update(percent)
        default :
            interacting = false
            if percent > interactivePrecent {
                percentTransition?.completionSpeed = 1.0 - percentTransition!.percentComplete
                percentTransition?.finish()
                dismissPanGesture?.removeTarget(self, action: #selector(slideTransition(_:)))
                percentTransition = nil
            } else {
                percentTransition?.cancel()
                percentTransition = UIPercentDrivenInteractiveTransition()
            }
        }
        
    }

    public var interacting: Bool = false
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        self.transitionContext = transitionContext
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let containView = transitionContext.containerView
        
        containView.addSubview(fromVC!.view)
        containView.addSubview(toVC!.view)
        toVC!.view.layer.opacity = 0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            toVC!.view.layer.opacity = 1
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
