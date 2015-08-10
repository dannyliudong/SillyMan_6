//
//  Shake.swift
//  SillyMan_6
//
//  Created by liudong on 15/8/10.
//  Copyright (c) 2015年 liudong. All rights reserved.
// 震动效果

import Foundation
import UIKit

enum ShakeDirection:Int {
    case ShakeDirectionHorizontal = 0
    case ShakeDirectionVertical
}

extension UIView {
    
    func shakeA(times:Int, delta:CGFloat) {
        self.shake(times, direction: 1, current: 0, delta: delta, interval: 0.03, shakeDirection: ShakeDirection.ShakeDirectionHorizontal)
    }
    
    func shakeB(times:Int, delta:CGFloat, interval:NSTimeInterval) {
        self.shake(times, direction: 1, current: 0, delta: delta, interval: interval, shakeDirection: ShakeDirection.ShakeDirectionHorizontal)
        
    }
    
    func shakeC(times:Int, delta:CGFloat, interval:NSTimeInterval, shakeDirection:ShakeDirection) {
        self.shake(times, direction: 1, current: 0, delta: delta, interval: interval, shakeDirection: ShakeDirection.ShakeDirectionHorizontal)
    }
    
    func shake(times:Int, direction:Int, current:Int, delta:CGFloat, interval:NSTimeInterval, shakeDirection:ShakeDirection) {
        UIView.animateWithDuration(interval, animations: { () -> Void in
            //
            let transformCG:CGAffineTransform = (shakeDirection == ShakeDirection.ShakeDirectionVertical) ? CGAffineTransformMakeTranslation(delta * CGFloat(direction), 0) : CGAffineTransformMakeTranslation(0, delta * CGFloat(direction))
            
            self.transform = transformCG
            
            }) { (finished:Bool) -> Void in
            //
                if current >= times {
                    self.transform = CGAffineTransformIdentity
                    return
                }
                
                self.shake(times - 1,
                    direction: direction * -1,
                    current: current + 1,
                    delta: delta,
                    interval: interval,
                    shakeDirection: shakeDirection)
                
        }
    }
    
}