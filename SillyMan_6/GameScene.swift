//
//  GameScene.swift
//  SpriteKitCameraCustom
//
//  Created by liudong on 15/8/19.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var Screen_Width:CGFloat!
    private var Screen_Height:CGFloat!
    
    var rootSceneNode:SKNode!
    var player:SKSpriteNode!
    
    private var adjustmentBackgroundPosition:CGFloat = 0 //调整背景位置
    
    private var background1:SKSpriteNode!
    private var background2:SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        Screen_Width = self.size.width
        Screen_Height = self.size.height
        
        backgroundColor = SKColor.lightGrayColor()
        
        //self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -2)

        rootSceneNode = SKNode()
        addChild(rootSceneNode)
        
        player = SKSpriteNode (imageNamed: "submarine1")
        player.position = CGPointMake(size.width/2, size.height/2)
        player.physicsBody?.allowsRotation = false
        
        player.physicsBody = SKPhysicsBody(texture: player.texture, size: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.angularDamping = 0.0
        
        rootSceneNode.addChild(player)
        
        createBackground()
        
        scoreLabel = SKLabelNode(fontNamed: "")
        addChild(scoreLabel)
        scoreLabel.position = CGPointMake(20, Screen_Height - 40)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left

    }
    
    
    //MARK: 创建背景层
    func createBackground() {
        
        adjustmentBackgroundPosition = self.size.width
        
        background1 = SKSpriteNode(imageNamed: "blackStoneDown1")
        background1.position = CGPointMake(0,  50)
        //background1.anchorPoint = CGPointMake(0, 0.5)
        background1.zPosition = -10
        rootSceneNode.addChild(background1)
        
//        background2 = SKSpriteNode(imageNamed: "blackStoneDown")
//        //background2.anchorPoint = CGPointMake(0, 0.5)
//        background2.zPosition = -10
//        background2.position = CGPointMake(background1.size.width - 1, 50);
//        rootSceneNode.addChild(background2)
        
        // 底部石头
//        let stone1 = SKSpriteNode(imageNamed: "blackStoneDown")
//        stone1.position = CGPointMake(Screen_Width/2 , -(Screen_Height/2 - stone1.size.height/2))
//        background1.addChild(stone1)
//        
//        let stone2 = SKSpriteNode(imageNamed: "blackStoneDown")
//        stone2.position = CGPointMake(Screen_Width/2,  -(Screen_Height/2 - stone1.size.height/2))
//        background2.addChild(stone2)
        
        background1.physicsBody = SKPhysicsBody(texture: background1.texture, size: background1.size)
        background1.physicsBody?.dynamic = false
        background1.physicsBody?.allowsRotation = false
        background1.physicsBody?.affectedByGravity = true
        
//        background2.physicsBody = SKPhysicsBody(texture: background2.texture, size: background2.size)
//        background2.physicsBody?.dynamic = false
//        background2.physicsBody?.allowsRotation = false
//        background2.physicsBody?.affectedByGravity = true
        
    }
    
    //MARK: 滚动背景层
    func scrollBackground() {
        
//        adjustmentBackgroundPosition--
//        
//        println("adj :\(adjustmentBackgroundPosition)")
//        
//        if (adjustmentBackgroundPosition <= 0) {
//            adjustmentBackgroundPosition = CGFloat(Screen_Width)
//        }
//        
//        background1.position = CGPointMake(CGFloat(adjustmentBackgroundPosition - CGFloat(self.size.width)), Screen_Height/2)
//        background2.position = CGPointMake(CGFloat(adjustmentBackgroundPosition - 1), Screen_Height/2)
        
        // 如果背景1 移动了屏幕宽度的距离 即视为离开屏幕
        
        //println("background2.x :\(background2.position.x)")
        
//        if background1.position.x <= background1.size.width {
//            background1.position.x = background2.position.x + background2.size.width
//        }
//        
//        if background2.position.x >= background1.size.width {
//            background1.position.x = background2.position.x + background2.size.width
//        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        player.physicsBody?.velocity = CGVectorMake(0, 0)
        player.physicsBody?.applyImpulse(CGVectorMake(1, 5))

    }
   
    private var isone:Int = 2
    private var odelta:CGFloat = 0
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        scrollBackground()
        
        player.position.x++
        let ptX = player.position.x
        
        //println("player.position.x : \(ptX)")
        rootSceneNode.position.x = -ptX + 100
        
        var delta = ptX-background1.position.x
        println("delta: \(delta)")
        if(isone == 2)
        {
            odelta = delta
            println("odelta :\(odelta)")
            isone = 0
        }
        if(delta-odelta>background1.size.width)
        {
            delta=delta-odelta
            
            if(isone==0)
            {
                isone=1
                background1.position.x+=background2.size.width
            }
            if(isone==1)
            {
                isone=0
                background2.position.x+=background1.size.width
            }
        }
        
        scoreLabel.text = "\(score)"
        
    }
}
