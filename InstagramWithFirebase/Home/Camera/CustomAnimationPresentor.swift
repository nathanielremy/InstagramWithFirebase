//
//  CustomAnimationPresentor.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 24/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit

class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    
    // How long will the transition be ?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // Custom animated transition logic
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) else { print("No fromView"); return }
        guard let toView = transitionContext.view(forKey: .to) else { print("No toView"); return }
        
        containerView.addSubview(toView)
        
        // Present the view at the far left
        let startingFrame = CGRect(x: -(toView.frame.width), y: 0, width: toView.frame.width, height: toView.frame.height)
        toView.frame = startingFrame
        
        // Animate the view to fill the whole screen
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            fromView.frame = CGRect(x: fromView.frame.width , y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}


















