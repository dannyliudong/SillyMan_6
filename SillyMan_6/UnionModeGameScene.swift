//
//  GameScene.swift
//  TinyWings
//
//  Created by liudong on 15/5/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//
import SpriteKit


class UnionModeGameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {

    // MARK: Properties
    
    // 为了适配iPhone6 缩放比例
    var scaleFactor: CGFloat!
    
    let ButtonSpaceX:CGFloat = 0.3 // 按钮 X间距
    let ButtonSpaceX1:CGFloat = 0.5
    let ButtonSpaceY:CGFloat = 1.3 // 按钮 Y间距
    let Button_Width:CGFloat = 70
    
    let playerOffset:CGFloat = 100
    
    let atlas = GameSpriteAtlas()
    
    //var playableRect: CGRect! //游戏区域
    
    var rootSceneNode:SKNode! // 根场景 所有元素的父节点 ，控制此节点移动模拟摄像机追踪
    
    var player: SKSpriteNode!
    var enemyNode: SKNode!
    var starNode: SKNode!
    
    var hillShape:SKShapeNode! // = SKShapeNode()
    
    var overUINode:SKNode! // GameOverUINode
    var pauseUINode:SKNode! // 游戏暂停UINode
    var homePageUINode:SKNode! // 主页UINode
    var gameSceneUINode: SKNode! // 游戏场景UINode
    var settingsUINode:SKNode! // 设置UI
    var homePageBottomButtonsNode:SKNode! // 主页底部按钮
    var gameOverbottomButtonNode:SKNode! // 游戏结束底部按钮
    
    var fadeInMaskNode:SKNode!
    var fadeOutMaskNode:SKNode!
    
    // 手势
    var longPressGesture:UILongPressGestureRecognizer!
    
    // 声音
    let starSound = SKAction.playSoundFileNamed("coin_steal_02.mp3", waitForCompletion: false)
    let enemySound = SKAction.playSoundFileNamed("crash.mp3", waitForCompletion: false)
    let playerScaleSound = SKAction.playSoundFileNamed("tunnelPlop.mp3", waitForCompletion: false)

    var pauseButton: SKSimpleButton!
    var musicButton:SKSimpleButton!
    var soundButton:SKSimpleButton!
    
    //MARK: 飞行距离 = 游戏时间 ＊ 移动速度(1米每秒)
    
    // 移动速度
    var playerMoveSpeed: CGFloat = 0.15/1
    // 游戏时间
    var playTime: CGFloat = 0

    var guideFigerNode: SKNode! // 指引手指
    
    //MARK: Private Properties
    //  得分
    private var starTotal:Int = 0
    private var flyAwayDistance:Int = 0
    
    // 当到某个条件时 改变等级难度
    private var enemyTypeLeve: EnemyType!
    private var enemySpeedLeve: CGFloat!
    
    //敌人移动的速度 星移动的速度
    private let enemySpeed:CGFloat = 380
    private let starSpeed: CGFloat = 200
    
    private var isGameOver = true
    private var isGameBegin = false
    private var isFristRuning = true // 是否首次运行游戏
    private var isOpenUI = false // 是否在主页打开了某些界面 如果打开了 游戏不会开始
    private var isPlayerMustScale = false // 角色

    private var scoreLabel: SKLabelNode!
    private var starsLabel: SKLabelNode!
    private var staricon: SKSpriteNode!
    
    private var score: Int = 0
    private var displayScore: Int = 0
    
    private var background1:SKSpriteNode!
    private var background2:SKSpriteNode!
    
    private var stone1:SKSpriteNode!
    private var stone2:SKSpriteNode!
    private var stone3:SKSpriteNode!
    private var stone4:SKSpriteNode!
    
    private var Screen_Width:CGFloat!
    private var Screen_Height:CGFloat!
    
    private var font_Name:String = "HelveticaNeue"
    
    let gameSong = "LocoRocosSong.mp3"
    
    //MARK: Did Move To View
    override func didMoveToView(view: SKView) {
        
        // setup physics
        self.physicsWorld.gravity = CGVectorMake( 0.0, -2.0 )
        self.physicsWorld.contactDelegate = self
        
        Screen_Width = self.size.width
        Screen_Height = self.size.height
        
        scaleFactor = Screen_Width / 320.0
        
        self.backgroundColor = SKColor.random
        
        // 引导手指
        figerNode()
        
        // 暂停控制按钮
        pauseButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_pause"))
        pauseButton.zPosition = 60
        pauseButton.name = "pauseButton"
        pauseButton.targetTouchUpInside = self
        pauseButton.actionTouchUpInside = "pauseGame" // 执行方法名
        pauseButton.position = CGPointMake(Screen_Width - Button_Width / 2, Screen_Height - Button_Width / 2)
        pauseButton.hidden = true
        addChild(pauseButton)
        
        //showHomePageUI()
        //showHomePageBottomButtons()
        
        isFristRuning = true
        isGameOver = false
        
        rootSceneNode = SKNode()
        addChild(rootSceneNode)
        
        createPlayer()
        
        
        for var i = 0; i < 10; i++ {
            createShapeBG()

        }

        //createPaoPao()
        createSnow()
        
        
        //  1.游戏开始前的音乐
//        SKTAudio.sharedInstance().playBackgroundMusic(gameSong)
//        
//        let music = GameState.sharedInstance.musicState
//        
//        if !music {
//            // 暂停音乐
//            SKTAudio.sharedInstance().pauseBackgroundMusic()
//        }
        
        
//        delay(seconds: 2.0) {
//            self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
//            
//            //spawn all the sand particles
//            self.runAction(
//                SKAction.repeatAction(
//                    SKAction.sequence([
//                        SKAction.runBlock(self.spawnSand),
//                        SKAction.waitForDuration(0.01)
//                        ])
//                    , count: 100)
//                
//            )
//            
//            //get seismic
//            //delay(seconds: 8, self.shake)
//        }
        
        
        // 长按手势操作
        longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPressGestureAction:")
        longPressGesture.minimumPressDuration = 0.2 // 最少按住时间
        
        self.view?.addGestureRecognizer(longPressGesture)
        

    }
    
    var isLongPress:Bool = false // 是否在长按屏幕
    var impulse_dy:CGFloat = 0
    
    func longPressGestureAction(sender:UILongPressGestureRecognizer) {

        // 长按添加一个向上的力 并且越来越强
        // 如果手指一直按着 ， 就会一直执行，并且数值不断增加

        if sender.state == UIGestureRecognizerState.Began {
            
            isLongPress = true
            
            println("长按")

        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            println("长按结束")
            isLongPress = false
            impulse_dy = 0.0
            
        }

    }

    //MARK: 随机生成
//    func createGameNodes() {
//        //  游戏开始后, 等待1秒开始生成敌人和星
//        runAction(SKAction.repeatActionForever(
//            SKAction.sequence([
//                SKAction.runBlock(createBarrier),
//                SKAction.waitForDuration(1.5)
//                ])
//            ))
//        
//        runAction(SKAction.repeatActionForever(
//            SKAction.sequence([
//                SKAction.waitForDuration(1.0),
//                SKAction.runBlock(cut01)])
//            ))
//    }
    
    var rotateFlag:Bool = true // 旋转方向 true: 逆时针方向， false:  顺时针方向
    
    //  引导手指
    func figerNode() {
        guideFigerNode = SKNode()
        guideFigerNode.xScale = 0.6
        guideFigerNode.yScale = 0.6
        
        guideFigerNode.zPosition = 50
        guideFigerNode.position = CGPoint(x: Screen_Width/2, y: Screen_Height/8)
        addChild(guideFigerNode)
        
        let fingerSprite = SKSpriteNode(texture: atlas.finger_finger01())
        guideFigerNode.addChild(fingerSprite)
        
        let fingerTouch = SKAction.animateWithTextures(atlas.finger_finger(), timePerFrame: 0.3)
        let fingerTouchAni = SKAction.repeatAction(fingerTouch, count: 6)
        let fingerTouchSequence = SKAction.repeatActionForever(SKAction.sequence([fingerTouchAni]))
        fingerSprite.runAction(fingerTouchSequence)
    }
    
    
    
    var leve = 0
    
    var starPoint1:CGPoint = CGPointMake(-10, -10)
    var starPoint2:CGPoint = CGPointMake(-10, 120)
    
    var endPoint:CGPoint!
    
    var lastPoint:CGPoint = CGPointMake(60, 20)
    
    var curveEndPointArray = [CGPoint]()
    //var ppBezierWidth:CGFloat = 30

    //MARK: 创建图形背景
    func createShapeBG() {
        
        // 绘制三次贝塞尔曲线
        let beizerPathThree = UIBezierPath()
        beizerPathThree.lineWidth = 5.0
        beizerPathThree.lineCapStyle = kCGLineCapRound
        beizerPathThree.lineJoinStyle = kCGLineJoinRound
        
        beizerPathThree.moveToPoint(starPoint1)
        beizerPathThree.addLineToPoint(starPoint2)
        
        let width = randomEndPointWidth()
        let ppBezierWidth = randomBezierWidth()
        
        if leve == 0 {
            // 偏下的位置
            endPoint = CGPointMake(self.lastPoint.x + width , randomEndPointLow())
            leve = 1
            
        } else if leve == 1 {
            endPoint = CGPointMake(self.lastPoint.x + width, randomEndPointHight()) // 偏上的位置
            leve = 0
        }
        
        let P1 = CGPointMake((lastPoint.x + ppBezierWidth), lastPoint.y)
        let P2 = CGPointMake(endPoint.x - ppBezierWidth, endPoint.y)
        
        beizerPathThree.addCurveToPoint(endPoint, controlPoint1: P1, controlPoint2: P2)
        
        // 收尾线
        

        
        lastPoint = endPoint
        
        
        println("lastPoint.x: \(lastPoint.x)")

        let closePoint = CGPointMake(lastPoint.x, -10)
        beizerPathThree.addLineToPoint(closePoint)
        
        starPoint1 = closePoint
        starPoint2 = lastPoint

//        for var i = 0; i < 100; i++ {
//            
//
//
//        }
        
        
        //  读取plist 设置
        // Load the level
//        let dataPlist = NSBundle.mainBundle().pathForResource("CurveData01", ofType: "plist")
//        let curveData = NSDictionary(contentsOfFile: dataPlist!)!
//        let items = curveData["CurvePoint"] as! [NSDictionary]
//        
//        for item in items {
//            
//            let endPoint = item["EndPoint"] as! NSDictionary
//            let p1 = item["p1"] as! NSDictionary
//            let p2 = item["p2"] as! NSDictionary
//            
//            let endPointX = endPoint["x"]!.floatValue
//            let endPointY = endPoint["y"]!.floatValue
//            
//            let p1X = p1["x"]!.floatValue
//            let p1Y = p1["y"]!.floatValue
//            
//            let p2X = p2["x"]!.floatValue
//            let p2Y = p2["y"]!.floatValue
//            
//            let curve_EndPoint = CGPointMake(CGFloat(endPointX), CGFloat(endPointY))
//            let P1 = CGPointMake(CGFloat(p1X), CGFloat(p1Y))
//            let P2 = CGPointMake(CGFloat(p2X), CGFloat(p2Y))
//            
//            beizerPathThree.addCurveToPoint(curve_EndPoint, controlPoint1: P1, controlPoint2: P2)
//            
//        }

//        var lastPointX:CGFloat!
//        if let lastItem = items.last {
//            let endPoint = lastItem["EndPoint"] as! NSDictionary
//            let endPointX = endPoint["x"]!.floatValue
//            lastPointX = CGFloat(endPointX)
//        }
        
        

        
        //beizerPathThree.stroke()
        
        hillShape = SKShapeNode()
        hillShape.position = CGPointMake(0, 0)
        hillShape.path = beizerPathThree.CGPath
        hillShape.lineWidth = 3
        hillShape.fillColor = UIColor.randomColor
        hillShape.strokeColor = SKColor.lightGrayColor()
        hillShape.glowWidth = 0
        hillShape.fillTexture = SKTexture(imageNamed: "bgte")
        hillShape.antialiased = true
        rootSceneNode.addChild(hillShape)
        
        hillShape.physicsBody = SKPhysicsBody(edgeLoopFromPath: beizerPathThree.CGPath)
//        beizerCurveThree.physicsBody?.friction = 0
//        beizerCurveThree.physicsBody?.charge = 0
//        beizerCurveThree.physicsBody?.restitution = 0
//        beizerCurveThree.physicsBody?.linearDamping = 0
//        beizerCurveThree.physicsBody?.angularDamping = 0
        hillShape.physicsBody?.dynamic = false
        hillShape.physicsBody?.allowsRotation = false
        hillShape.physicsBody?.affectedByGravity = true
        hillShape.physicsBody?.categoryBitMask = CollisionCategoryBitmask.SeaBottom
        
    }
    
    // 山丘高点位置范围 随机值
    func randomEndPointHight() ->CGFloat {
        return CGFloat(arc4random_uniform(100) + 100)
    }
    
    // 山丘低点位置范围 随机值
    func randomEndPointLow() ->CGFloat {
        return CGFloat(arc4random_uniform(30) + 10)
    }
    
    //  曲线宽度 随机
    func randomEndPointWidth () ->CGFloat {
        return CGFloat(arc4random_uniform(200) + 200)
    }
    
    //  角度横向值 随机
    func randomBezierWidth () ->CGFloat {
        return CGFloat(arc4random_uniform(50) + 50)
    }


    //MARK: 创建背景层
    func createBackground() {
        
        let bgcolor = UIColor.random
        
        background1 = SKSpriteNode(color: bgcolor, size: self.size) //SKSpriteNode(imageNamed: "BG1")
        background1.position = CGPointMake(background1.size.width/2, Screen_Height/2)
        background1.zPosition = -10
        rootSceneNode.addChild(background1)
        
        println("background1 size: \(background1.size)")
        
        background2 = SKSpriteNode(color: bgcolor, size: self.size) //SKSpriteNode(imageNamed: "BG1")
        background2.zPosition = -10
        background2.position = CGPointMake((background1.position.x + background1.size.width), Screen_Height/2);
        rootSceneNode.addChild(background2)
        
        // 底部石头
        stone1 = SKSpriteNode(imageNamed: "blackStoneDown")
        stone1.position = CGPointMake(0, -((background1.size.height / 2) + stone1.size.height/2))
        background1.addChild(stone1)
        
        stone2 = SKSpriteNode(imageNamed: "blackStoneDown")
        stone2.position = CGPointMake(0, -((background1.size.height / 2) + stone1.size.height/2))
        background2.addChild(stone2)
        
        stone1.physicsBody = SKPhysicsBody(texture: stone1.texture, size: stone1.size)
        stone1.physicsBody?.friction = 0
        stone1.physicsBody?.charge = 0
        stone1.physicsBody?.restitution = 0
        stone1.physicsBody?.linearDamping = 0
        stone1.physicsBody?.angularDamping = 0
        stone1.physicsBody?.dynamic = false
        stone1.physicsBody?.allowsRotation = false
        stone1.physicsBody?.affectedByGravity = true
        stone1.physicsBody?.categoryBitMask = CollisionCategoryBitmask.SeaBottom
        
        stone2.physicsBody = SKPhysicsBody(texture: stone2.texture, size: stone2.size)
        stone2.physicsBody?.friction = 0
        stone2.physicsBody?.charge = 0
        stone2.physicsBody?.restitution = 0
        stone2.physicsBody?.linearDamping = 0
        stone2.physicsBody?.angularDamping = 0
        stone2.physicsBody?.dynamic = false
        stone2.physicsBody?.allowsRotation = false
        stone2.physicsBody?.affectedByGravity = true
        stone2.physicsBody?.categoryBitMask = CollisionCategoryBitmask.SeaBottom
        
        
        // 顶部石头
        stone3 = SKSpriteNode(imageNamed: "blackStoneTop")
        stone3.position = CGPointMake(0, Screen_Height/2 - (stone3.size.height/2 - 10))
        background1.addChild(stone3)
        
        stone4 = SKSpriteNode(imageNamed: "blackStoneTop")
        stone4.position = CGPointMake(0, Screen_Height/2 - (stone3.size.height/2 - 10)) //background1.size.height/2 + stone4.size.height/2
        background2.addChild(stone4)
        
        stone3.physicsBody = SKPhysicsBody(texture: stone3.texture, size: stone3.size)
        stone3.physicsBody?.friction = 0
        stone3.physicsBody?.charge = 0
        stone3.physicsBody?.restitution = 0
        stone3.physicsBody?.linearDamping = 0
        stone3.physicsBody?.angularDamping = 0
        stone3.physicsBody?.dynamic = false
        stone3.physicsBody?.allowsRotation = false
        stone3.physicsBody?.affectedByGravity = true
        stone3.physicsBody?.categoryBitMask = CollisionCategoryBitmask.SeaBottom
        
        stone4.physicsBody = SKPhysicsBody(texture: stone4.texture, size: stone4.size)
        stone4.physicsBody?.friction = 0
        stone4.physicsBody?.charge = 0
        stone4.physicsBody?.restitution = 0
        stone4.physicsBody?.linearDamping = 0
        stone4.physicsBody?.angularDamping = 0
        stone4.physicsBody?.dynamic = false
        stone4.physicsBody?.allowsRotation = false
        stone4.physicsBody?.affectedByGravity = true
        stone4.physicsBody?.categoryBitMask = CollisionCategoryBitmask.SeaBottom
        
    }
    
    
    func createSnow() {
        var snow = SKEmitterNode.emitterNamed("Snow")
        snow.position = CGPointMake(Screen_Width/2, 0)
        addChild(snow)
    }
    
    func createPaoPao() {
        let starfieldNode = SKNode()
        starfieldNode.alpha = 0.8
        starfieldNode.zPosition = -9
        starfieldNode.name = "paopao"
        starfieldNode.addChild(starfieldEmitterNode(
            speed: -18, lifetime: size.height / 23, scale: 0.6,
            birthRate: 1, color: SKColor.orangeColor()))
        addChild(starfieldNode)
    }
    
    func starfieldEmitterNode(#speed: CGFloat, lifetime: CGFloat, scale: CGFloat, birthRate: CGFloat, color: SKColor) -> SKEmitterNode {
        
        let sk = SKSpriteNode(imageNamed: "paopao")
        sk.alpha = 0.5
        
        let textureView = SKView()
        let texture = textureView.textureFromNode(sk)
        texture.filteringMode = .Nearest
        
        let emitterNode = SKEmitterNode()
        emitterNode.particleTexture = texture
        emitterNode.particleBirthRate = birthRate
        emitterNode.particleColor = color
        emitterNode.particleLifetime = lifetime
        emitterNode.particleSpeed = speed
        emitterNode.particleScale = scale
        emitterNode.particleColorBlendFactor = 1
        emitterNode.position =
            CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame))
        emitterNode.particlePositionRange =
            CGVector(dx: CGRectGetMaxX(frame), dy: 0)
        
        emitterNode.particleAction =
            SKAction.repeatActionForever(SKAction.sequence([
                SKAction.rotateByAngle(CGFloat(-M_PI_4), duration: 1),
                SKAction.rotateByAngle(CGFloat(M_PI_4), duration: 1)]))
        
        emitterNode.particleSpeedRange = 16.0
        
        //1
        let twinkles = 20
        let colorSequence = SKKeyframeSequence(capacity: twinkles*2)
        //2
        let twinkleTime = 1.0/CGFloat(twinkles)
        for i in 0..<twinkles {
            //3
            colorSequence.addKeyframeValue(
                SKColor.whiteColor(),time: CGFloat(i)*2 * twinkleTime/2)
            colorSequence.addKeyframeValue(
                SKColor.yellowColor(), time: (CGFloat(i)*2+1)*twinkleTime/2)
        }
        //4
        emitterNode.particleColorSequence = colorSequence
        
        emitterNode.advanceSimulationTime(NSTimeInterval(lifetime))
        
        return emitterNode
    }
    
    //MARK:随机障碍物
    func createCollisionScene() {
        
    }
    
    // 构建怪物
    func createBarrier() ->SKSpriteNode {
        
        //let randomEnemyY = CGFloat.random(Int(self.size.height) +  20 )
        
        let bow = SKSpriteNode(imageNamed: randomEmenyName())
        bow.name = "Bow"
        bow.position = CGPointMake(CGFloat.random(min: 10, max: background1.size.width), CGFloat.random(min: 10, max: background1.size.height))
        bow.zPosition = 50
        
        bow.physicsBody = SKPhysicsBody(texture: bow.texture, size: bow.size)
        bow.physicsBody?.dynamic = false
        bow.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        bow.physicsBody?.collisionBitMask = 0
        bow.physicsBody?.contactTestBitMask = 0
        
        let moveDonw = SKAction.moveToY(-50, duration: 3.0)
        let moveUp = SKAction.moveToY(300, duration: 3.0)
        
        let seuqueAction = SKAction.sequence([moveDonw,moveUp])
        
        bow.runAction(SKAction.repeatActionForever(seuqueAction))
        
        return bow
    }

    var moveCount:Int = 0
    var playerLastPostionX:CGFloat = 0


    //MARK: 滚动背景层
    func scrollBackground() {
        
        player.position.x = player.position.x+4
        rootSceneNode.position.x = -player.position.x + playerOffset
        score = max(score, Int(player.position.x))
        
        displayScore = Int(Double(score - Int(playerOffset)) * 0.1)
        
        scoreLabel.text = "\(Int(displayScore))"

        var count = Int(abs(rootSceneNode.position.x ) / background1.size.width)
        if  count != moveCount {
            moveCount = count
            
            var bowCount:Int = 3
            
            for var i = 0; i < bowCount; i++ {
                let bow = createBarrier()
                rootSceneNode.addChild(bow)
            }
            
            
            if moveCount % 2 != 0 {
                background1.position.x = background2.position.x + background2.size.width
                // 生成敌人和障碍 预加载进场景
                
                stone1.removeAllChildren()
                stone3.removeAllChildren()
                
                for var i = 0; i < bowCount; i++ {
                    let bow = createBarrier()
                    stone1.addChild(bow)
                    
                }
            }
            if moveCount % 2 == 0 {
                background2.position.x = background1.position.x + background1.size.width
                // 生成敌人和障碍 预加载进场景
                
                stone2.removeAllChildren()
                stone4.removeAllChildren()
                
                for var i = 0; i < bowCount; i++ {
                    let bow = createBarrier()
                    stone2.addChild(bow)
                    
                }
                
            }
            
        }
        
        // 角色高度超过一定高度 缩放根场景 达到远景效果
//        if player.position.y >= Screen_Height * 0.8 {
//            rootSceneNode.runAction(SKAction.scaleTo(0.8, duration: 0.5))
//        }
//        if player.position.y <= Screen_Height * 0.8  {
//            rootSceneNode.runAction(SKAction.scaleTo(1, duration: 0.5))
//        }
        
    }
    
    
    override func didSimulatePhysics() {
        
    }
    
    // MARK:碰撞委托方法 protocol Method
    
    
    // 碰撞开始
    func didBeginContact(contact: SKPhysicsContact) {
        
        if !isGameOver {
            
            let other = (contact.bodyA.categoryBitMask == CollisionCategoryBitmask.Player ? contact.bodyB : contact.bodyA)
            
            switch other.categoryBitMask {
            case CollisionCategoryBitmask.Star:
                let starNode = other.node
                collisionBeginWithStar(starNode!)
                
            case CollisionCategoryBitmask.Enemy:
                let enemyNode = other.node
                collisionBeginWithEnemy(player)
                
            case CollisionCategoryBitmask.SeaBottom :
                collisionBeginSeaBottom(player)
                
            default:
                break;
            }
            
        }
    }
    
    
    // 碰撞结束
    func didEndContact(contact: SKPhysicsContact) {
        if !isGameOver {
            
            let other = (contact.bodyA.categoryBitMask == CollisionCategoryBitmask.Player ? contact.bodyB : contact.bodyA)
            
            switch other.categoryBitMask {
            case CollisionCategoryBitmask.Star:
                println("Collision Star")
                
            case CollisionCategoryBitmask.Enemy:
                println("Collision Enemy")
            case CollisionCategoryBitmask.SeaBottom :
                collisionEndSeaBottom(player)
                
            default:
                break;
            }
            
        }
    }
    

    


    func collisionEndSeaBottom(node:SKNode) {
        println("collisionEndSeaBottom")
    }
    
    // 撞到敌人
    func collisionBeginWithEnemy(node:SKNode) {
        
        collisionByBoat(node)
        node.removeFromParent()
        
    }
    
    var collisionSeaBottomCuount = 0
    //  碰撞海底
    func collisionBeginSeaBottom(node:SKNode) {
        //collisionByBoat(player)
        //playerScleToBig(player)
    }
    
    
    // 碰到边缘 会膨胀变大  增加难度
    func playerScleToBig(node:SKNode) {
        println("playerScleToBig")
        let sceletobig = SKAction.scaleTo(2.0, duration: NSTimeInterval(0.5), delay: NSTimeInterval(0.0), usingSpringWithDamping: CGFloat(0.5), initialSpringVelocity: CGFloat(0.5))
        let scaletoNor = SKAction.scaleTo(0.8, duration: 0.5)
        
        node.runAction(SKAction.sequence([sceletobig, scaletoNor]))
        
        //runAction(playerScaleSound)
    }
    
    
    //MARK: 碰撞结果执行
    func collisionBeginWithStar(node:SKNode) {
        let musicOn = GameState.sharedInstance.musicState
        if musicOn {
            runAction(starSound, completion: { () -> Void in
                node.removeFromParent()
            })
        } else {
            node.removeFromParent()
        }
        
        //GameState.sharedInstance.stars += 1
        updateHUD()
        
    }
    
    //  飞船撞毁
    func collisionByBoat(node:SKNode) {
        
        let musicOn = GameState.sharedInstance.musicState
        if musicOn {
            
            impulse_dy = 0.0
            isLongPress = false
            
            
            //  震屏
            shakeCarema()
            
            showParticlesForEnemy(node)
            player.physicsBody?.allowsRotation = true
            
            //boatCrash()
            player.removeFromParent()
            
            runAction(enemySound)
            
            gameOver()
        } else {
            
            impulse_dy = 0.0
            isLongPress = false
            
            
            //  震屏
            shakeCarema()
            
            showParticlesForEnemy(node)
            player.physicsBody?.allowsRotation = true
            
            //boatCrash()
            player.removeFromParent()
            
            gameOver()
        }
    }

    
    
    //  飞船解体
    func boatCrash() {
        
        var node = SKNode()
        node.position = player.position
        rootSceneNode.addChild(node)
        
        var boatNode1 = SKSpriteNode(imageNamed: "submarineNode01")
        var boatNode2 = SKSpriteNode(imageNamed: "submarineNode02")
        var boatNode3 = SKSpriteNode(imageNamed: "submarineNode03")
        var boatNode4 = SKSpriteNode(imageNamed: "submarineNode04")
        var boatNode5 = SKSpriteNode(imageNamed: "submarineNode05")
        
        node.addChild(boatNode1)
        node.addChild(boatNode2)
        node.addChild(boatNode3)
        node.addChild(boatNode4)
        node.addChild(boatNode5)
        
        boatNode1.physicsBody = SKPhysicsBody(texture: boatNode1.texture, size: boatNode1.size)
        boatNode1.physicsBody?.dynamic = true
        boatNode1.physicsBody?.allowsRotation = true
        boatNode1.physicsBody?.affectedByGravity = true
        
        boatNode2.physicsBody = SKPhysicsBody(texture: boatNode2.texture, size: boatNode2.size)
        boatNode2.physicsBody?.dynamic = true
        boatNode2.physicsBody?.allowsRotation = true
        boatNode2.physicsBody?.affectedByGravity = true
        
        boatNode3.physicsBody = SKPhysicsBody(texture: boatNode3.texture, size: boatNode3.size)
        boatNode3.physicsBody?.dynamic = true
        boatNode3.physicsBody?.allowsRotation = true
        boatNode3.physicsBody?.affectedByGravity = true
        
        boatNode4.physicsBody = SKPhysicsBody(texture: boatNode4.texture, size: boatNode4.size)
        boatNode4.physicsBody?.dynamic = true
        boatNode4.physicsBody?.allowsRotation = true
        boatNode4.physicsBody?.affectedByGravity = true
        
        boatNode5.physicsBody = SKPhysicsBody(texture: boatNode5.texture, size: boatNode5.size)
        boatNode5.physicsBody?.dynamic = true
        boatNode5.physicsBody?.allowsRotation = true
        boatNode5.physicsBody?.affectedByGravity = true
        
    }
    
    //MARK: 粒子特效
    
    //  撞击震屏
    func shakeCarema() {
        let sceneView = self.view
        if let view = sceneView {
            view.shakeC(10, delta: 5, interval: 0.03, shakeDirection: ShakeDirection.ShakeDirectionVertical)
        }
    }
    
    // 撞击敌人 死亡特效
    func showParticlesForEnemy(node: SKNode) {
        
        let emitter = SKEmitterNode.emitterNamed("Bow")
        emitter.particleTexture!.filteringMode = .Nearest
        emitter.position = node.position
        emitter.zPosition = 100
        
        emitter.runAction(SKAction.removeFromParentAfterDelay(0.4))
        rootSceneNode.addChild(emitter)
    }
    
    // 金币特效
    func showParticlesForGold(node: StarNode) {
        
        let emitter = SKEmitterNode.emitterNamed("GoldSplatter")
        emitter.particleTexture!.filteringMode = .Nearest
        emitter.position = node.position
        
        emitter.runAction(SKAction.removeFromParentAfterDelay(0.4))
        rootSceneNode.addChild(emitter)
    }
    
    // 点击特效
    func tapEffectsForTouchAtLocation(location: CGPoint) {
        showTapAtLocation(location)
    }
    
    func showTapAtLocation(point: CGPoint) {
        let shapeNode = SKShapeNode()
        
        let path = UIBezierPath(ovalInRect: CGRect(x: -3, y: -3, width: 6, height: 6))
        shapeNode.path = path.CGPath

        shapeNode.position = point
        shapeNode.strokeColor = SKColorWithRGBA(255, 255, 255, 196)
        shapeNode.lineWidth = 1
        shapeNode.antialiased = false
        shapeNode.zPosition = 100
        addChild(shapeNode)
        // 3
        let duration = 0.6
        let scaleAction = SKAction.scaleTo(6.0, duration: duration)
        scaleAction.timingMode = .EaseOut
        shapeNode.runAction(SKAction.sequence(
            [scaleAction, SKAction.removeFromParent()]))
        // 4
        let fadeAction = SKAction.fadeOutWithDuration(duration)
        fadeAction.timingMode = .EaseOut
        shapeNode.runAction(fadeAction)
    }
    
    
    func updateHUD() {
        // 更新分数
        scoreLabel.text = "\(displayScore)"
        let scaleIn = SKAction.scaleTo(1.5, duration: 0.1)
        let scaleOut = SKAction.scaleTo(1.5, duration: 0.2)
        scoreLabel.runAction(SKAction.sequence([scaleIn, scaleOut])) //starsLabel.yScale
        
    }
    
    
    //MARK: 构建游戏Node
    //  动态创建敌人
//    func createEnemy() {
//        
//        if !isGameOver {
//            
//            let randomEnemyX = CGFloat.random(Int(self.size.width) +  20 )
//            
//            self.enemyNode = self.creatEnemyformPosition(CGPointMake(randomEnemyX, self.playableRect.size.height + 50), ofType: self.enemyTypeLeve)
//            
//            let node = self.enemyNode as! EnemyNode
//            self.addChild(node)
//            
//            let targetPostion = -self.playableRect.size.height + 50
//            let bornPostion = self.playableRect.size.height + 50
//            
//            let totaltime:NSTimeInterval = NSTimeInterval((bornPostion - targetPostion) / enemySpeed)
//            
//            if node.enemyType == EnemyType.Normal {
//                // 普通敌人
//                let actionMove = SKAction.moveToY(-self.playableRect.size.height + 50, duration: totaltime * NSTimeInterval(enemySpeedLeve))
//                let actionMoveDone = SKAction.removeFromParent()
//                
//                node.runAction(SKAction.sequence([actionMove, actionMoveDone]))
//                
//            } else if node.enemyType == EnemyType.SpecialRotate {
//                // 旋转敌人
//                let actionMove = SKAction.moveToY(-self.playableRect.size.height + 50, duration: totaltime * NSTimeInterval(enemySpeedLeve))
//                let actionMoveDone = SKAction.removeFromParent()
//                
//                var actionRotate: SKAction!
//                
//                if self.rotateFlag {
//                    // 逆时针旋转
//                    actionRotate = SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.5)
//                    
//                } else {
//                    // 顺时针旋转
//                    actionRotate = SKAction.rotateByAngle(CGFloat(-M_PI), duration: 0.5)
//                }
//                
//                let rotateAni = SKAction.repeatActionForever(actionRotate)
//                
//                let groupAni = SKAction.group([rotateAni, actionMove])
//                
//                node.runAction(SKAction.sequence([groupAni, actionMoveDone]))
//                
//                
//                
//            } else if node.enemyType == EnemyType.SpecialActive {
//                // 移动敌人
//                let actionMove = SKAction.moveToY(-self.playableRect.size.height + 50, duration: totaltime * NSTimeInterval(enemySpeedLeve))
//                
//                let actionMoveDone = SKAction.removeFromParent()
//                var actionMoveByself = SKAction()
//                
//                if node.position.x <= self.playableRect.size.width/2 {
//                    actionMoveByself = SKAction.moveToX(CGRectGetMaxX(self.playableRect), duration: totaltime * NSTimeInterval(enemySpeedLeve))
//                    node.runAction(actionMove)
//                } else if node.position.x >= self.playableRect.size.width/2 {
//                    actionMoveByself = SKAction.moveToX(CGRectGetMinX(self.playableRect), duration: totaltime * NSTimeInterval(enemySpeedLeve))
//                    node.runAction(actionMove)
//                }
//                
//                let moveAni = SKAction.repeatActionForever(actionMoveByself)
//                
//                let groupAni = SKAction.group([moveAni, actionMove])
//                
//                node.runAction(SKAction.sequence([groupAni, actionMoveDone]))
//                
//                
//            } else if node.enemyType == EnemyType.SpecialHidden {
//                // 隐身敌人
//                let actionMove = SKAction.moveToY(-self.playableRect.size.height + 50, duration: totaltime * NSTimeInterval(enemySpeedLeve))
//                
//                let actionMoveDone = SKAction.removeFromParent()
//                
//                let actionHidden = SKAction.fadeAlphaTo(CGFloat(0.2), duration: 0.5)
//                
//                let groupAni = SKAction.group([actionHidden, actionMove])
//                
//                node.runAction(SKAction.sequence([groupAni, actionMoveDone]))
//                
//            }
//            
//        }
//        
//    }
    

    
    // 构建导弹
    func cut01() {
        
        let randomEnemyY = CGFloat.random(Int(self.size.height) +  20 )
        
        let bow = SKSpriteNode(imageNamed: "cut01")
        bow.position = CGPointMake(Screen_Width * 1.5, randomEnemyY)
        bow.zPosition = 50
        background1.addChild(bow)
        
        bow.physicsBody = SKPhysicsBody(texture: bow.texture, size: bow.size)
        bow.physicsBody?.dynamic = false
        bow.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        bow.physicsBody?.collisionBitMask = 0
        bow.physicsBody?.contactTestBitMask = 0
        
//        let move = SKAction.moveToX(-100, duration: 4)
//        let movedone = SKAction.removeFromParent()
//        bow.runAction(SKAction.sequence([move, movedone]))
        
    }
    
    
    //构建player
    func createPlayer(){
        let playerName = String.random
        player = SKSpriteNode (imageNamed: playerName)
        player.position = CGPointMake(playerOffset, Screen_Height/2)
        player.shadowCastBitMask = UInt32(3)
        
        rootSceneNode.addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture, size: player.size)
        player.physicsBody?.dynamic = false
        player.physicsBody?.allowsRotation = true
        player.physicsBody?.affectedByGravity = true
        
//        player.physicsBody?.friction = 0.2
//        player.physicsBody?.charge = 0
//        player.physicsBody?.restitution = 0
//        player.physicsBody?.linearDamping = 0
//        player.physicsBody?.angularDamping = 0
        
        player.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        player.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Enemy | CollisionCategoryBitmask.SeaBottom
        
        
        //let emitter = SKEmitterNode.emitterNamed("missileFire")
        //emitter.particleTexture!.filteringMode = .Nearest
        
        //emitter.runAction(SKAction.removeFromParentAfterDelay(0.4))
        //player.addChild(emitter)
        
        
        
        //        let smileSprite = SKSpriteNode(texture: atlas.face_1_face_1_001())
        //        _node.addChild(smileSprite)
        //
        //        let smile = SKAction.animateWithTextures(atlas.face_1_face_1_(), timePerFrame: 0.1)
        //        let smileAni = SKAction.repeatAction(smile, count: 6)
        //        let smileSequence = SKAction.repeatActionForever(SKAction.sequence([smileAni]))
        //        smileSprite.runAction(smileSequence)
        
        //        let emitter = SKEmitterNode.emitterNamed("PlayerTrail")
        //        emitter.particleTexture!.filteringMode = .Nearest
        //        emitter.position = CGPointMake(0, 100)
        //        smileSprite.addChild(emitter)
    }
    
    // 创建敌人
    func creatEnemyformPosition(position: CGPoint, ofType type: EnemyType) ->EnemyNode {
        
        let _node = EnemyNode()
        _node.name = "enemyNode"
        
        // 随机位置
        _node.position = CGPoint(x: position.x, y: position.y )
        _node.enemyType = type
        
        let sprite = SKSpriteNode(imageNamed: "missile")
        _node.addChild(sprite)
        
        _node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        
        return _node
        
    }
    
    // 创建星星
//    func createStar() {
//        if !isGameOver {
//            
//            let sprite = SKSpriteNode(imageNamed: "Star")
//            addChild(sprite)
//            
//            // 随机位置
//            let randomEnemyY = CGFloat.random(Int(self.size.height) +  20 )
//            sprite.position = CGPointMake(Screen_Width * 1.1, randomEnemyY)
//            
//            sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
//            sprite.physicsBody?.dynamic = false
//            sprite.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
//            sprite.physicsBody?.collisionBitMask = 0
//            sprite.physicsBody?.contactTestBitMask = 0
//            
//            //
//            let targetPostion = -self.playableRect.size.height + 50
//            let bornPostion = self.playableRect.size.height + 50
//            
//            // 移动的速度
//            let totaltime:NSTimeInterval = NSTimeInterval((bornPostion - targetPostion) / starSpeed)
//
//            let move = SKAction.moveToX(-100, duration: 4)
//            let movedone = SKAction.removeFromParent()
//            sprite.runAction(SKAction.sequence([move, movedone]))
//        }
//        
//    }

    //MARK: 开始游戏
    func starGame() {
        isGameOver = false
        isGameBegin = true
        
        player.physicsBody?.dynamic = true
        
        self.pauseButton.hidden = false
        
        //homePageUINode.removeFromParent()
        guideFigerNode.removeFromParent()
        //homePageBottomButtonsNode.removeFromParent()
        
        showGameSceneUI()
        
        // 2. 游戏开始后的音乐
        let music = GameState.sharedInstance.musicState
        if music {
            // 播放音乐
            SKTAudio.sharedInstance().playBackgroundMusic(gameSong)
        }
        
        //createGameNodes()
        

        
    }
    
    //MARK:  暂停游戏
    func pauseGame() {
        
        showGamePauseUI()
        
        isGameBegin = false
        println("....暂停游戏")
        
        // 1 游戏暂停
        //gamePause = true
        
        pauseButton.hidden = true
        
        // 2 保存游戏分数和进度
        GameState.sharedInstance.saveState()
        
        self.paused = true
        
    }
    
    //MARK: 继续游戏
//    func continueGame() {
//        self.view?.paused = false
//        //gamePause = false
//        isGameBegin = true
//        
//        println("....继续游戏")
//        
//        pauseButton.hidden = false
//        
//        pauseUINode.removeFromParent()
//    }
    
    //MARK: 游戏结束
    func gameOver() {
        
        isGameBegin = false
        self.isGameOver = true
        self.pauseButton.removeFromParent()

        self.view?.removeGestureRecognizer(longPressGesture)
        
        //SKTAudio.sharedInstance().pauseBackgroundMusic()
        
        // 保存游戏状态 分数等信息
        GameState.sharedInstance.currentScore = Int(displayScore)
        GameState.sharedInstance.saveState()
        
        // 获取所有enemyNode 销毁掉
        self.enumerateChildNodesWithName("enemyNode", usingBlock: { (node:SKNode!, _) -> Void in
            let enemy = node as! EnemyNode
            enemy.removeFromParent()
        })
        
        //  用dispatch_after推迟任务
        let delayInSeconds = 0.5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            
            self.showiAd()
            
            let delayInSeconds = 0.5
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            
            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                
                self.showGameOverBottomButtons()
                self.updateHUD()
            }
            
        }
        
    }
    
    // 重新开始游戏 切换至LoadingScene 
    func gameOverToLoadingScene() {
        
        let move = SKAction.moveToY(-100, duration: 0.2)
        let moveDone = SKAction.removeFromParent()
        let seque = SKAction.sequence([move, moveDone])
        gameOverbottomButtonNode.runAction(seque)
        
        //  用dispatch_after推迟任务
        let delayInSeconds = 0.2
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            
            //self.fadeInMask()
            self.goLoadingScene()
            
//            let delayInSeconds = 1.0
//            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
//            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
//                
//                self.goLoadingScene()
//            }
        }
        
    }
    
    //MARK: 转场遮罩
    func fadeOutMask() {
        // 淡出
        
        fadeOutMaskNode = SKNode()
        addChild(fadeOutMaskNode)
        
        let maskSp = SKSpriteNode(color: SKColor.orangeColor(), size: self.size)
        maskSp.alpha = 1
        maskSp.zPosition = 160
        maskSp.position = CGPointMake(self.Screen_Width/2, self.Screen_Height/2)
        fadeOutMaskNode.addChild(maskSp)
        
        let fadeAlphaAction = SKAction.fadeAlphaTo(0, duration: 0.5)
        let wait = SKAction.waitForDuration(0.5)
        let done = SKAction.removeFromParent()
        
        maskSp.runAction(SKAction.sequence([fadeAlphaAction, wait, done]))
    }
    
    func fadeInMask() {
        // 淡入
        fadeInMaskNode = SKNode()
        addChild(fadeInMaskNode)
        
        let maskSp = SKSpriteNode(color: SKColor.orangeColor(), size: self.size)
        maskSp.alpha = 0
        maskSp.zPosition = 160
        maskSp.position = CGPointMake(self.Screen_Width/2, self.Screen_Height/2)
        fadeInMaskNode.addChild(maskSp)
        
        let fadeAlphaAction = SKAction.fadeAlphaTo(1, duration: 0.5)
        let wait = SKAction.waitForDuration(0.5)
        let done = SKAction.removeFromParent()
        
        maskSp.runAction(SKAction.sequence([fadeAlphaAction, wait, done]))
    }
    
    //MARK:界面控制
    
    // 打开设置
    func openSettingsPage() {
        guideFigerNode.hidden = true
        openSettingsUI()
        isOpenUI = true
    }
    
    // 关闭设置
    func closeSettingsPage() {
        guideFigerNode.hidden = false
        settingsUINode.removeFromParent()
        isOpenUI = false
    }
    
    // 打开分享
    func openSharePage() {
        println("打开分享")
        
    }
    
    //  打开排行榜
    func openTopCharts() {
        println("打开排行榜")
    }
    
    // 开始游戏
    func palyGame() {
        println("开始游戏")
    }
    
    // 显示游戏场景UI
    func showGameSceneUI() {
        
        gameSceneUINode = SKNode()
        addChild(gameSceneUINode)
        
        // 飞行米数
        scoreLabel = SKLabelNode(fontNamed: font_Name)
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x:25 , y: Screen_Height-30)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.text = "\(Int(score))"
        gameSceneUINode.addChild(scoreLabel)
        
//        // 金币图标
//        let staricon = SKSpriteNode(imageNamed: "Star")
//        staricon.position = CGPoint(x: 25, y: self.size.height-30)
//        staricon.setScale(0.8)
//        gameSceneUINode.addChild(staricon)
//        
//        // 金币数量
//        starsLabel = SKLabelNode(fontNamed: font_Name)
//        starsLabel.fontSize = 24
//        starsLabel.fontColor = SKColor.whiteColor()
//        starsLabel.position = CGPoint(x: 50, y: self.size.height-40)
//        starsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
//        starsLabel.text = String(format: "%d", GameState.sharedInstance.stars)
//        gameSceneUINode.addChild(starsLabel)
        
    }
    
    // 打开选角色
    func openCharacterUI() {
        println("选择角色💃。。。。")
    }
    
    // 打开设置
    func openSettingsUI() {
        settingsUINode = SKNode()
        settingsUINode.position = CGPointMake(Screen_Width/2, self.size.height/2)
        settingsUINode.zPosition = 150
        addChild(settingsUINode)
        
        // 遮罩
        let maskSprite = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        maskSprite.alpha = 0.8
        maskSprite.zPosition = -10
        settingsUINode.addChild(maskSprite)
        
        // 关闭界面
        let closeButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_back"))//SKSimpleButton(imageNamed: "button_back")
        closeButton.name = "gohomeButton"
        closeButton.targetTouchUpInside = self
        closeButton.actionTouchUpInside = "closeSettingsPage" // 执行方法名
        closeButton.position = CGPointMake(-Screen_Width/2 + closeButton.size.width/1.5, self.size.height/2 - closeButton.size.height/1.5)
        settingsUINode.addChild(closeButton)
        
        // 选择语言
        let languageButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_language"))//SKSimpleButton(imageNamed: "button_language")
        languageButton.name = "gohomeButton"
        languageButton.targetTouchUpInside = self
        languageButton.actionTouchUpInside = "languageButtonAction" // 执行方法名
        languageButton.position = CGPointMake(0, 100)
        settingsUINode.addChild(languageButton)
        
        let languageLabel = SKLabelNode(fontNamed: font_Name)
        languageLabel.fontSize = 20
        languageLabel.position = CGPointMake(100,100)
        languageLabel.text = String(format: "语言")
        settingsUINode.addChild(languageLabel)

        // 音乐控制按钮
        musicButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_sound"))//SKSimpleButton(imageNamed: "button_sound")
        musicButton.name = "gohomeButton"
        musicButton.targetTouchUpInside = self
        musicButton.actionTouchUpInside = "musicButtonAction" // 执行方法名
        musicButton.position = CGPointMake(0, 50)
        
        settingsUINode.addChild(musicButton)
        
    }
    
    // 显示游戏结束主页底部按钮
    func showGameOverBottomButtons () {
        
        gameOverbottomButtonNode = SKNode()
        gameOverbottomButtonNode.zPosition = 150
        gameOverbottomButtonNode.position = CGPointMake(Screen_Width/2, 0)
        addChild(gameOverbottomButtonNode)
        
        // 分享按钮
        let shareButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_share"))//SKSimpleButton(imageNamed: "button_share")
        shareButton.name = "shareButton"
        shareButton.targetTouchUpInside = self
        shareButton.actionTouchUpInside = "openSharePage" // 执行方法名
        shareButton.position = CGPointMake(-(100 * scaleFactor), 0)
        gameOverbottomButtonNode.addChild(shareButton)
        
        // 开始按钮
        let palyButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_play"))//SKSimpleButton(imageNamed: "button_play")
        palyButton.name = "palyButton"
        palyButton.targetTouchUpInside = self
        palyButton.actionTouchUpInside = "gameOverToLoadingScene" // 执行方法名
        palyButton.position = CGPointMake(0, 0)
        gameOverbottomButtonNode.addChild(palyButton)
        
        // 排行按钮
        let topChartsButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_topCharts"))//SKSimpleButton(imageNamed: "button_topCharts")
        topChartsButton.name = "topChartsButton"
        topChartsButton.targetTouchUpInside = self
        topChartsButton.actionTouchUpInside = "openTopCharts" // 执行方法名
        topChartsButton.position = CGPointMake(100 * scaleFactor, 0)
        gameOverbottomButtonNode.addChild(topChartsButton)
        
        // 界面动画
        let action = SKAction.moveToY(40, duration: 0.2)
        action.timingMode = SKActionTimingMode.EaseInEaseOut
        let fadeAlpha = SKAction.fadeAlphaTo(1, duration: 0.2)
        gameOverbottomButtonNode.runAction(SKAction.group([action, fadeAlpha]))
        
    }
    
    // 显示主页底部按钮
    func showHomePageBottomButtons() {
        
        homePageBottomButtonsNode = SKNode()
        homePageBottomButtonsNode.zPosition = 100
        homePageBottomButtonsNode.position = CGPointMake(Screen_Width/2, 0)
        addChild(homePageBottomButtonsNode)
        
        // 选择角色按钮
        let characterButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "homeButton_Character1"))
        characterButton.name = "characterButton"
        characterButton.targetTouchUpInside = self
        characterButton.actionTouchUpInside = "openCharacterUI" // 执行方法名
        characterButton.position = CGPointMake(-(120 * scaleFactor), 40)
        homePageBottomButtonsNode.addChild(characterButton)
        
        let rot1 = SKAction.rotateToAngle(CGFloat(M_PI * 0.6), duration: 0.2)
        let rot2 = SKAction.rotateToAngle(-CGFloat(M_PI * 0.6), duration: 0.2)
        let wait = SKAction.waitForDuration(0.5)
        
        //characterButton.runAction(SKAction.repeatActionForever(SKAction.sequence([rot1, rot2, wait])))
        
        // 设置按钮
        let settingsButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_settings"))
        settingsButton.name = "settingsButton"
        settingsButton.targetTouchUpInside = self
        settingsButton.actionTouchUpInside = "openSettingsPage" // 执行方法名
        settingsButton.position = CGPointMake(120 * scaleFactor, 40)
        homePageBottomButtonsNode.addChild(settingsButton)
    }
    
    //  游戏结束 显示广告页， 弹出观看广告赢金币按钮
    func showiAd() {
        //  进行控制出现广告，有时候出现看广告赚金币按钮，有时候其它 参考天天过马路
        
        let iAdNode = SKNode()
        iAdNode.zPosition = 150
        iAdNode.position = CGPointMake(Screen_Width/2, Screen_Height/2)
        addChild(iAdNode)
        
        let belt = SKSpriteNode(color: SKColor.orangeColor(), size: CGSize(width: Screen_Width, height: 1))
        belt.alpha = 0.9
        iAdNode.addChild(belt)
        
        let scaleAction = SKAction.scaleYTo(60, duration: 0.1)
        belt.runAction(scaleAction)
        
        
        
        
        let label = SKLabelNode(fontNamed: font_Name)
        label.text = "Top:\(GameState.sharedInstance.highScore)"
        label.position = CGPointMake(-Screen_Width/2, -5)
        iAdNode.addChild(label)
        
        let moveAction = SKAction.moveToX(0, duration: 0.3)
        label.runAction(moveAction)
    }
    
    
    //  显示主页UI
    func showHomePageUI() {
        
        homePageUINode = SKNode()
        homePageUINode.zPosition = 50
        addChild(homePageUINode)
        
        // 分数榜
        let logoSprite = SKSpriteNode(imageNamed: "logoTitleSp")
        logoSprite.position = CGPointMake(Screen_Width/2, self.size.height - 80)
        homePageUINode.addChild(logoSprite)
        
        let highScoreLabel = SKLabelNode(fontNamed: font_Name)
        highScoreLabel.fontSize = 24
        highScoreLabel.blendMode = SKBlendMode.Add
        highScoreLabel.position = CGPoint(x: 0, y: -logoSprite.size.height/5)
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        highScoreLabel.text = "😈  \(GameState.sharedInstance.highScore)  😈"
        logoSprite.addChild(highScoreLabel)
        
        // 金币图标
        let staricon = SKSpriteNode(imageNamed: "Star")
        staricon.position = CGPoint(x: 25, y: self.size.height-30)
        staricon.setScale(0.8)
        homePageUINode.addChild(staricon)
        
        // 金币数量
        starsLabel = SKLabelNode(fontNamed: font_Name)
        starsLabel.fontSize = 24
        starsLabel.fontColor = SKColor.whiteColor()
        starsLabel.position = CGPoint(x: 50, y: self.size.height-40)
        starsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        //starsLabel.text = String(format: "%d", GameState.sharedInstance.stars)
        homePageUINode.addChild(starsLabel)
        
    }
    
    // 显示暂停界面
    func showGamePauseUI() {
        
        pauseUINode = SKNode()
        pauseUINode.zPosition = 60
        pauseUINode.position = CGPointMake(self.size.width/2, self.size.height/2)
        addChild(pauseUINode)
        
        // 遮罩
        let maskSprite = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        maskSprite.alpha = 0.3
        pauseUINode.addChild(maskSprite)
        
        // 回主页按钮
        let gohomeButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_quit")) //SKSimpleButton(imageNamed: "button_quit")
        gohomeButton.name = "gohomeButton"
        gohomeButton.targetTouchUpInside = self
        gohomeButton.actionTouchUpInside = "goLoadingScene" // 执行方法名 跳转主场景
        gohomeButton.position = CGPointMake(-self.size.width/4, -self.size.height/5)
        pauseUINode.addChild(gohomeButton)
        
        // 继续按钮
        let continueButton = SKSimpleButton(normalTexture: SKTexture(imageNamed: "button_play")) //SKSimpleButton(imageNamed: "button_play")
        continueButton.name = "continueButton"
        continueButton.targetTouchUpInside = self
        continueButton.actionTouchUpInside = "pauseContinue" // 执行方法名
        continueButton.position = CGPointMake(self.size.width/4, -self.size.height/5)
        pauseUINode.addChild(continueButton)
        
    }
    
    // 显示结束界面1
    func showGameOverFlash() {
        let overNode =  SKNode()
        addChild(overNode)
        
        // 遮罩
        let maskSprite = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        maskSprite.alpha = 0.3
        maskSprite.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        addChild(maskSprite)
        
        
        let logo = SKSpriteNode(imageNamed: "")
        
        
        overNode.position = CGPointMake(0, self.size.height/2)
        
        let move = SKAction.moveToX(self.size.width/2, duration: 1)
        let moveDone = SKAction.removeFromParent()
        let seque = SKAction.sequence([move, moveDone])
        
        overNode.runAction(seque)
        
    }
    
    // 显示结束界面
    func showGameOverUI() {
        
        overUINode = SKNode()
        overUINode.position = CGPointMake(self.size.width/2, self.size.height/2)
        overUINode.zPosition = 60
        overUINode.alpha = 0
        addChild(overUINode)
        
        // 遮罩
        let maskSprite = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        maskSprite.alpha = 0.3
        maskSprite.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        addChild(maskSprite)
        
        let splogo = SKSpriteNode(imageNamed: "text-gameover")
        splogo.position = CGPointMake(0, 0)
        overUINode.addChild(splogo)
        
        let scoreTotalLabel = SKLabelNode(fontNamed: font_Name)
        scoreTotalLabel.position = CGPointMake(0, 0)
        scoreTotalLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        //scoreTotalLabel.text = String(format: "收集金币: %d", GameState.sharedInstance.stars)
        overUINode.addChild(scoreTotalLabel)
        
        let distanceLabel = SKLabelNode(fontNamed: font_Name)
        distanceLabel.position = CGPointMake(0, -40)
        distanceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        //distanceLabel.text = String(format: "飞行距离: %d", GameState.sharedInstance.movingScore)
        overUINode.addChild(distanceLabel)
        
        let scoreHigthLabel = SKLabelNode(fontNamed: font_Name)
        scoreHigthLabel.position = CGPointMake(0, -80)
        scoreHigthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreHigthLabel.text = String(format: "最高纪录: %d", GameState.sharedInstance.highScore)
        overUINode.addChild(scoreHigthLabel)
        
        // 界面动画
        let palyerFistAction = SKAction.moveToY(self.size.height/1.5, duration: 0.3)
        palyerFistAction.timingMode = SKActionTimingMode.EaseInEaseOut
        let fadeAlpha = SKAction.fadeAlphaTo(1, duration: 0.2)
        overUINode.runAction(SKAction.group([palyerFistAction, fadeAlpha]))
        
    }
    
    // 关闭结算界面
    func closeGameOverUI() {
        
        let palyerFistAction = SKAction.moveToY(self.size.height + 200 , duration: 0.3)
        palyerFistAction.timingMode = SKActionTimingMode.EaseInEaseOut
        
        let fadeAlpha = SKAction.fadeAlphaTo(0, duration: 0.2)
        let closeDone = SKAction.removeFromParent()
        
        let groupAn = SKAction.group([palyerFistAction, fadeAlpha])
        let sequenceAn = SKAction.sequence([groupAn, closeDone])
        
        overUINode.runAction(sequenceAn)
        
    }
    
    // MARK: 按钮事件
    
    //  选择语言
    func languageButtonAction() {
        println("选择语言")
    }
    
    // 音乐开关
    func musicButtonAction() {
        let music = GameState.sharedInstance.musicState
        println(music)

        if music {
            // 如果是开的 就暂停音乐            
            SKTAudio.sharedInstance().pauseBackgroundMusic()
            GameState.sharedInstance.musicState = false
            GameState.sharedInstance.saveState()
            
        } else {
            // 恢复音乐播放
            //self.musicButton = SKSimpleButton(imageNamed: "button_sound_off")
            
            SKTAudio.sharedInstance().resumeBackgroundMusic()
            GameState.sharedInstance.musicState = true
            GameState.sharedInstance.saveState()
        }
        
    }
    
    // 跳转场景
    func goLoadingScene() {
        let loadingScene = LoadingScene(size: self.size)
        self.view?.presentScene(loadingScene)
    }
    

    // 暂停游戏 ->继续
    func pauseContinue() {
        
        isGameBegin = true
        //isGameOver = true
        
        print("暂停游戏 ->继续")
        
        self.paused = false
        pauseUINode.removeFromParent()
        pauseButton.hidden = false        
        
//    self.view?.paused = false
//    //gamePause = false
//    isGameBegin = true
//
//    println("....继续游戏")
//
//    pauseButton.hidden = false
//
//    pauseUINode.removeFromParent()
        
    }
    
    // 求角色移动所需的时间
    func playMovingTime(p1:CGPoint, p2:CGPoint, speed:CGFloat) ->CGFloat{
        var time:CGFloat = 0
        
        // 移动时间 = 距离/速度
        // 距离 = sqrt( (p1.x - p0.x) * (p1.x - p0.x) +  (p1.y - p0.y) * (p1.y - p0.y) )
        
        let juli:CGFloat! = sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
        let moveSpeed:CGFloat! = speed
        
        time = juli / moveSpeed
        
        return time
    }
    
    //MARK: 点击事件
    private var state = 0
    
    private var Player_Move_Speed:CGFloat = 300
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if !isGameOver && !isOpenUI {
            
            let touch = touches.first as! UITouch
            let locationInNode = touch.locationInNode(self)

            let tagetPoint:CGPoint = locationInNode
            let playerPoint:CGPoint = player.position
            
            let moveTime = playMovingTime(playerPoint, p2: tagetPoint, speed: Player_Move_Speed)
            
            if isFristRuning {
                starGame()
                isFristRuning = false
            }
            
            //player.runAction(SKAction.moveTo(locationInNode, duration: Double(moveTime)))
            tapEffectsForTouchAtLocation(locationInNode)
            
            
            if player.position.y <= Screen_Height - player.size.height/2 {
                
                //player.physicsBody?.velocity = CGVectorMake(0, 0)
                //player.physicsBody?.applyImpulse(CGVectorMake(0, 10))
                wake()
            }
            
        }
        
    }
    
    var awake = false
    
    func wake() {
        awake = true
        player.physicsBody?.applyImpulse(CGVectorMake(5, 10))
    }
    
    func dive() {
        player.physicsBody?.applyImpulse(CGVectorMake(0, 10))
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        isLongPress = false
    }
    
    
    func moveBG() {
        
        player.position.x = player.position.x+4
        rootSceneNode.position.x = -player.position.x + playerOffset
        score = max(score, Int(player.position.x))
        
        displayScore = Int(Double(score - Int(playerOffset)) * 0.1)
        
        scoreLabel.text = "\(Int(displayScore))"
    }
    
    var lastSpawnTimeInterval:NSTimeInterval  = 0// 上次更新时间
    var lastUpdateTimeInterval: NSTimeInterval = 0
    
    override func update(currentTime: CFTimeInterval) {
        
        if isGameBegin {
            //scrollBackground()
            moveBG()
            // 如果角色超出顶部 解除用力
            if player.position.y >= Screen_Height - player.size.height/2 {
                isLongPress = false
                impulse_dy = 0.0
            }
            
            if isLongPress {
                player.physicsBody?.applyImpulse(CGVectorMake(0, -1.7))
            }
        }
        
    }
    
    func randomEmenyName() ->String{
        switch arc4random()%4 {
        case 0: return "EmenyModel_01"
        case 1: return "zhangyu"
        case 2: return "zhangyu"
        case 3: return "EmenyModel_01"
        default: return "EmenyModel_01"
        }
    }
    
    func randomStarMoon() -> SKTexture{
        
        switch arc4random()%4 {
        case 0: return atlas.bgstar_bgstarmoon_0001()
        case 1: return atlas.bgstar_bgstarmoon_0002()
        case 2: return atlas.bgstar_bgstarmoon_0003()
        case 3: return atlas.bgstar_bgstarmoon_0004()
        default: return atlas.bgstar_bgstarmoon_0004()
        }
    }
    
    func randomColor() ->SKColor{
        
        var color = CGFloat(CGFloat(random())/CGFloat(RAND_MAX))
        var color1 = CGFloat(CGFloat(random())/CGFloat(RAND_MAX))
        var color2 = CGFloat(CGFloat(random())/CGFloat(RAND_MAX))
        var color3 = CGFloat(CGFloat(random())/CGFloat(RAND_MAX))
        
        let bgcolor = UIColor(red: color, green: color1, blue: color2, alpha: 0.8)
        
        return bgcolor
        
    }
}


// MARK: - Extensions

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension String {
    static var random: String {
        switch arc4random()%8 {
        case 0: return "playerModel_01"
        case 1: return "playerModel_02"
        case 2: return "playerModel_03"
        case 3: return "playerModel_04"
        case 4: return "playerModel_05"
        case 5: return "playerModel_06"
        case 6: return "playerModel_07"
        case 7: return "playerModel_08"
        case 8: return "playerModel_09"
        default: return "playerModel_01"
        }
    }
}


private extension SKColor {
    class var random: SKColor {
        switch arc4random()%8 {
        case 0: return UIColor(red: 188.0/255.0, green: 217.0/255.0, blue: 247.0/255.0, alpha: 1)
        case 1: return UIColor(red: 78.0/255.0, green: 152.0/255.0, blue: 181.0/255.0, alpha: 1)
        case 2: return UIColor(red: 238.0/255.0, green: 239.0/255.0, blue: 221.0/255.0, alpha: 1)
        case 3: return UIColor(red: 53.0/255.0, green: 80.0/255.0, blue: 75.0/255.0, alpha: 1)
        case 4: return UIColor(red: 233.0/255.0, green: 216.0/255.0, blue: 162.0/255.0, alpha: 1)
        case 5: return UIColor(red: 194.0/255.0, green: 213.0/255.0, blue: 219.0/255.0, alpha: 1)
        case 6: return UIColor(red: 121.0/255.0, green: 156.0/255.0, blue: 150.0/255.0, alpha: 1)
        case 7: return UIColor(red: 251.0/255.0, green: 212.0/255.0, blue: 137.0/255.0, alpha: 1)
        default: return UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1)
        }
    }
}

private extension SKColor {
    class var randomColor: SKColor {
        switch arc4random()%8 {
        case 0: return SKColor.redColor()
        case 1: return SKColor.greenColor()
        case 2: return SKColor.blueColor()
        case 3: return SKColor.cyanColor()
        case 4: return SKColor.yellowColor()
        case 5: return SKColor.magentaColor()
        case 6: return SKColor.orangeColor()
        case 7: return SKColor.purpleColor()
        default: return SKColor.blackColor()
        }
    }
}

private extension SKAction {
    class var randomEnemyType: EnemyType {
        switch arc4random()%5 {
        case 0: return EnemyType.Normal
        case 1: return EnemyType.SpecialRotate
        case 2: return EnemyType.SpecialActive
        case 3: return EnemyType.SpecialHidden
        default: return EnemyType.Normal
        }
    }
}




