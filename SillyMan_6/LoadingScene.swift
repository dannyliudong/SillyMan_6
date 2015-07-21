//
//  LoadingScene.swift
//  
//
//  Created by liudong on 15/7/17.
//
//

import UIKit
import SpriteKit

class LoadingScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = SKColor.whiteColor()
    }
    
    
    override func didMoveToView(view: SKView) {
        // 放切换动画
        // 切换场景
        
//        let bgMask = SKSpriteNode(color: SKColor.blueColor(), size: self.size)
//        bgMask.position = CGPointMake(self.size.width/2, self.size.height/2)
//        bgMask.alpha = 0
//        addChild(bgMask)
//        
//        let toA = SKAction.fadeAlphaTo(1, duration: 0.5)
//        let wait = SKAction.waitForDuration(0.5)
//        let toB = SKAction.fadeAlphaTo(0, duration: 1)
//        
//        let seque = SKAction.sequence([toA, wait, toB])
//        
//        bgMask.runAction(seque) { () -> Void in
//            let gameScene = UnionModeGameScene(size: self.size)
//            self.view?.presentScene(gameScene)
//        }
        
        
        
        
//        class func crossFadeWithDuration(sec: NSTimeInterval) -> SKTransition
//        
//        class func fadeWithDuration(sec: NSTimeInterval) -> SKTransition
//        
//        class func fadeWithColor(color: UIColor, duration sec: NSTimeInterval) -> SKTransition
//        
//        class func flipHorizontalWithDuration(sec: NSTimeInterval) -> SKTransition
//        class func flipVerticalWithDuration(sec: NSTimeInterval) -> SKTransition
//        
//        class func revealWithDirection(direction: SKTransitionDirection, duration sec: NSTimeInterval) -> SKTransition
//        class func moveInWithDirection(direction: SKTransitionDirection, duration sec: NSTimeInterval) -> SKTransition
//        class func pushWithDirection(direction: SKTransitionDirection, duration sec: NSTimeInterval) -> SKTransition
//        
//        class func doorsOpenHorizontalWithDuration(sec: NSTimeInterval) -> SKTransition
//        class func doorsOpenVerticalWithDuration(sec: NSTimeInterval) -> SKTransition
//        class func doorsCloseHorizontalWithDuration(sec: NSTimeInterval) -> SKTransition
//        class func doorsCloseVerticalWithDuration(sec: NSTimeInterval) -> SKTransition
//        
//        class func doorwayWithDuration(sec: NSTimeInterval) -> SKTransition
        
        
        
        let transition = SKTransition.crossFadeWithDuration(0.5)
        
        let gameScene = UnionModeGameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: transition)
        
        //  用dispatch_after推迟任务
//        let delayInSeconds = 0.5
//        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
//        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
//            
//            let reveal = SKTransition.fadeWithDuration(0.5)
//            let gameScene = UnionModeGameScene(size: self.size)
//            self.view?.presentScene(gameScene, transition: reveal)
//        }
        
    }
    
}
