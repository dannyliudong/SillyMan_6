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
    }
    
    
    override func didMoveToView(view: SKView) {
        // 放切换动画
        // 切换场景

        let transition = SKTransition.crossFadeWithDuration(0.5)
        
        let gameScene = UnionModeGameScene(size: self.size)
        self.view?.presentScene(gameScene)
        

        
    }
    
}
