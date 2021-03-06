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
    
    //private var adjustmentBackgroundPosition:CGFloat = 0 //调整背景位置
    
    private var background1:SKSpriteNode!
    private var background2:SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        Screen_Width = self.size.width
        Screen_Height = self.size.height
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -2)

        rootSceneNode = SKNode()
        addChild(rootSceneNode)
        
        player = SKSpriteNode (imageNamed: "submarine1")
        player.position = CGPointMake(150, 100)
        player.physicsBody = SKPhysicsBody(texture: player.texture, size: player.size)
        player.physicsBody?.dynamic = true
        
        rootSceneNode.addChild(player)
        
        createBackground()
        
        scoreLabel = SKLabelNode(fontNamed: "")
        addChild(scoreLabel)
        scoreLabel.position = CGPointMake(20, Screen_Height - 40)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left

    }
    
    
    //MARK: 创建背景层
    func createBackground() {
        
        background1 = SKSpriteNode(imageNamed: "BG1")
        background1.position = CGPointMake(background1.size.width/2, Screen_Height/2)
        background1.zPosition = -10
        rootSceneNode.addChild(background1)
        
        background2 = SKSpriteNode(imageNamed: "BG1")
        background2.zPosition = -10
        background2.position = CGPointMake((background1.position.x + background1.size.width), Screen_Height/2);
        rootSceneNode.addChild(background2)
        
        // 底部石头
        let stone1 = SKSpriteNode(imageNamed: "blackStoneDown1")
        stone1.position = CGPointMake(0, -background1.size.height/2 + stone1.size.height/2)
        background1.addChild(stone1)

        let stone2 = SKSpriteNode(imageNamed: "blackStoneDown1")
        stone2.position = CGPointMake(0, -background1.size.height/2 + stone1.size.height/2)
        background2.addChild(stone2)
        
        stone1.physicsBody = SKPhysicsBody(texture: stone1.texture, size: stone1.size)
        stone1.physicsBody?.angularVelocity
        stone1.physicsBody?.dynamic = false
        stone1.physicsBody?.allowsRotation = false
        stone1.physicsBody?.affectedByGravity = true
        
        stone2.physicsBody = SKPhysicsBody(texture: stone2.texture, size: stone2.size)
        stone2.physicsBody?.dynamic = false
        stone2.physicsBody?.allowsRotation = false
        stone2.physicsBody?.affectedByGravity = true
        
    }
    
    
    var moveCount:Int = 0
    
    //MARK: 滚动背景层
    func scrollBackground() {
        
        player.position.x++
        
        score = max(score, Int(player.position.x))  //score : Int(player.position.x)
        
        let ptX = player.position.x
        rootSceneNode.position.x = -ptX + 150
        
        var count = Int(abs(rootSceneNode.position.x ) / background1.size.width)
        if  count != moveCount {
            moveCount = count
            
            if moveCount % 2 != 0 {
                background1.position.x = background2.position.x + background2.size.width
            }
            if moveCount % 2 == 0 {
                background2.position.x = background1.position.x + background1.size.width
            }

        }
        

//        if spaceX >= scrollBG.size.width {
//            
//            background1.position.x = background2.position.x + background2.size.width
//            scrollBG = background2
//        }
//        
//        
//        
//        if  spaceX < background1.size.width {
//            
//            background1.position.x = background2.position.x + background2.size.width
//        }
        
//        var delta = ptX-background1.position.x
//        println("delta: \(delta)")
//        if(isone == 2)
//        {
//            odelta = delta
//            println("odelta :\(odelta)")
//            isone = 0
//        }
//        if(delta-odelta>background1.size.width)
//        {
//            delta=delta-odelta
//
//            if(isone==0)
//            {
//                isone=1
//                background1.position.x+=background2.size.width
//            }
//            if(isone==1)
//            {
//                isone=0
//                background2.position.x+=background1.size.width
//            }
//        }
        

        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        player.physicsBody?.applyImpulse(CGVectorMake(3, 5))
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        scrollBackground()
        player.physicsBody?.applyImpulse(CGVector(dx: 0.1, dy: 0))
        
        let displayScore = Double(score - 150) * 0.1
        scoreLabel.text = "\(Int(displayScore))"
        
    }
    
}
