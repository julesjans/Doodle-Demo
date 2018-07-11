//
//  Animator.swift
//  Eye
//
//  Created by Julian Jans on 02/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit
import CoreMotion

class EyeAnimator {
    
    static let shared = EyeAnimator()
    
    let motionManager = CMMotionManager()
    var currentRotation: CGFloat?
    var animators = [UIDynamicAnimator]()

    private init() {
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {
            (motion, error) in
            let grav : CMAcceleration = motion!.gravity;
            let x = CGFloat(grav.x);
            let y = CGFloat(grav.y);
            let v = CGVector(dx: x, dy: (0 - y));
            self.animators.forEach({ $0.behaviors.filter({ $0 is UIGravityBehavior }).forEach({ ($0 as! UIGravityBehavior).gravityDirection = v})})
            self.currentRotation = CGFloat(atan2(motion!.gravity.x, motion!.gravity.y) - .pi)
        })
    }
    
    func animate(eye: Eye) {
        
        let animator = UIDynamicAnimator(referenceView: eye)
        
        let gravity = UIGravityBehavior()
        gravity.addItem(eye.iris)
        animator.addBehavior(gravity)
    
        let collision = UICollisionBehavior(items: [eye.iris])
        collision.translatesReferenceBoundsIntoBoundary = true
        collision.addBoundary(withIdentifier: "CircleBoundary" as NSCopying, for: UIBezierPath.init(ovalIn: eye.bounds))
        animator.addBehavior(collision)
        
        func randomFloat() -> CGFloat {
            return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        }
        
        let dynamicBehaviour = UIDynamicItemBehavior(items: [eye.iris])
        dynamicBehaviour.density = randomFloat()
        dynamicBehaviour.elasticity = randomFloat()
        dynamicBehaviour.friction = randomFloat()
        dynamicBehaviour.resistance = randomFloat()
        dynamicBehaviour.allowsRotation = true
        animator.addBehavior(dynamicBehaviour)
        
        animators.append(animator)
    }
    
    func clear(eye: Eye) {
        
//        self.animators.forEach { (animator) in
//            animator.behaviors.forEach({ (behaviour) in
//                behaviour.
//            })
//        }
//
        animators.forEach({$0.removeAllBehaviors()})
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

