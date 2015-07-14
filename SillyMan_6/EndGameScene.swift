//
//  AppDelegate.swift
//  TinyWings
//
//  Created by liudong on 15/5/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import SpriteKit

class EndGameScene: SKScene {
    
    var star = SKSpriteNode()
    var lblStars = SKLabelNode()
    var lblScore = SKLabelNode()
    var lblHighScore = SKLabelNode()
    var lblTryAgain = SKLabelNode()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = UIColor.purpleColor()
        // Stars
        star = SKSpriteNode(imageNamed: "yellowStar")
        star.setScale(0.8)
        star.position = CGPoint(x: 25, y: self.size.height-30)
        addChild(star)
        
        lblStars = SKLabelNode(fontNamed: "HelveticaNeue")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.whiteColor()
        lblStars.position = CGPoint(x: 50, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        addChild(lblStars)
        
        // Score
        lblScore = SKLabelNode(fontNamed: "HelveticaNeue")
        lblScore.fontSize = 40
        lblScore.fontColor = SKColor.yellowColor()
        lblScore.position = CGPoint(x: self.size.width / 2, y: 300)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblScore.text = String(format: "本次得分: %d", GameState.sharedInstance.stars)
        addChild(lblScore)
        
        // High Score
        lblHighScore = SKLabelNode(fontNamed: "HelveticaNeue")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.redColor()
        lblHighScore.position = CGPoint(x: self.size.width / 2, y: 150)
        lblHighScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblHighScore.text = String(format: "最高纪录: %d", GameState.sharedInstance.highScore)
        addChild(lblHighScore)

        
        // Try again
        lblTryAgain = SKLabelNode(fontNamed: "HelveticaNeue")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.whiteColor()
        lblTryAgain.position = CGPoint(x: self.size.width / 2, y: 50)
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblTryAgain.text = "点击重玩"
        addChild(lblTryAgain)

    }
        
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        star.removeFromParent()
        lblStars.removeFromParent()
        lblScore.removeFromParent()
        lblHighScore.removeFromParent()
        lblTryAgain.removeFromParent()
        
        // 切换回游戏场景
        let reveal = SKTransition.doorsOpenHorizontalWithDuration(1)
        
        let gameScene = UnionModeGameScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
    
}
   

