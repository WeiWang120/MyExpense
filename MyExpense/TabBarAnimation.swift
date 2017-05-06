//
//  CustomTabAnimatedTransitioning.swift
//  CustomTabBar
//
//  Created by Adam Bardon on 01/04/16.
//  Copyright © 2016 Swift Joureny. All rights reserved.
//

import UIKit

class CustomTabAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            let fromView = fromVC.view
            let toView = toVC.view
            
            let containerView = transitionContext.containerView
            
            containerView.clipsToBounds = false
            containerView.addSubview(toView!)
            
            var fromViewEndFrame = fromView?.frame
            fromViewEndFrame?.origin.x -= (containerView.frame.width)
            
            let toViewEndFrame = transitionContext.finalFrame(for: toVC)
            var toViewStartFrame = toViewEndFrame
            toViewStartFrame.origin.x += (containerView.frame.width)
            toView?.frame = toViewStartFrame
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                toView?.frame = toViewEndFrame
                fromView?.frame = fromViewEndFrame!
                }, completion: { (completed) -> Void in
                    fromView?.removeFromSuperview()
                    transitionContext.completeTransition(completed)
                    containerView.clipsToBounds = true
            })
        }
    }
    
}
