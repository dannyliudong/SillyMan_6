//
//  GameScene.swift
//  TinyWings
//
//  Created by liudong on 15/5/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//
import SpriteKit


class UnionModeGameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: Properties
    
    // 为了适配iPhone6 缩放比例
    var scaleFactor: CGFloat!
    
    let ButtonSpaceX:CGFloat = 0.3 // 按钮 X间距
    let ButtonSpaceX1:CGFloat = 0.5
    let ButtonSpaceY:CGFloat = 1.3 // 按钮 Y间距
    let Button_Width:CGFloat = 70
    
    let atlas = GameSpriteAtlas()
    
    var playableRect: CGRect! //游戏区域
    var playerNode: SKNode!
    var enemyNode: SKNode!
    var starNode: SKNode!
    
    var overUINode:SKNode! // GameOverUINode
    var pauseUINode:SKNode! // 游戏暂停UINode
    var homePageUINode:SKNode! // 主页UINode
    var gameSceneUINode: SKNode! // 游戏场景UINode
    var settingsUINode:SKNode! // 设置UI
    var homePageBottomButtonsNode:SKNode! // 主页底部按钮
    var gameOverbottomButtonNode:SKNode! // 游戏结束底部按钮
    
    var fadeInMaskNode:SKNode!
    var fadeOutMaskNode:SKNode!
    
    // 声音
    let starSound = SKAction.playSoundFileNamed("coin_steal_02.mp3", waitForCompletion: false)
    let enemySound = SKAction.playSoundFileNamed("collisionSound.wav", waitForCompletion: false)

    var pauseButton: SKSimpleButton!
    var musicButton:SKSimpleButton!
    var soundButton:SKSimpleButton!
    
    //MARK: 飞行距离 = 游戏时间 ＊ 移动速度(1米每秒)
    
    // 移动速度
    var playerMoveSpeed: CGFloat = 0.15/1
    // 游戏时间
    var playTime: CGFloat = 0
    // 飞行距离
    var movingExtent:Int = 0 {
        didSet{
            //gameLeveDataControlle()
        }
    }
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
    
    private var scoreLabel: SKLabelNode!
    private var starsLabel: SKLabelNode!
    private var staricon: SKSpriteNode!
    
    private var backgroundNode: SKNode!
    private var background1:SKSpriteNode!
    private var background2:SKSpriteNode!
    
    private var Screen_Width:CGFloat!
    private var Screen_Height:CGFloat!
    
    private var font_Name:String = "HelveticaNeue"
    
    private var adjustmentBackgroundPosition:CGFloat = 0 //调整背景位置
    
    
    //MARK: Did Move To View
    override func didMoveToView(view: SKView) {
        
        // setup physics
        self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 )
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        let skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        Screen_Width = self.size.width
        Screen_Height = self.size.height
        
        scaleFactor = Screen_Width / 320.0
        self.playableRect = CGRect(x: 0, y: 0 , width: Screen_Width, height: Screen_Height)
        
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
        
        showHomePageUI()
        showHomePageBottomButtons()
        
        isFristRuning = true
        isGameOver = false
        
        self.playerNode = createPlayer()
        addChild(playerNode)
        
        createBackground()
        
        //  1.游戏开始前的音乐
        SKTAudio.sharedInstance().playBackgroundMusic("night_1_v3.mp3")
        
        let music = GameState.sharedInstance.musicState
        
        if !music {
            // 暂停音乐
            SKTAudio.sharedInstance().pauseBackgroundMusic()
        }

    }
    
    func createGameNodes() {
        //  游戏开始后, 等待1秒开始生成敌人和星
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(createBarrier),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
//        runAction(SKAction.repeatActionForever(
//            SKAction.sequence([
//                SKAction.waitForDuration(5.0),
//                SKAction.runBlock(createStar)])
//            ))
    }
    
    
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
    

    //MARK: 创建背景层
    func createBackground() {
        
        adjustmentBackgroundPosition = self.size.width
        
        backgroundNode = SKNode()
        backgroundNode.zPosition = -10
        addChild(backgroundNode)
        
        background1 = SKSpriteNode(imageNamed: "BG1")
        background1.position = CGPointMake(0.0, self.size.height/2)
        background1.anchorPoint = CGPointMake(0.0, 0.5);
        //background1.setScale(scaleFactor)
        background1.zPosition = 0;
        
        background2 = SKSpriteNode(imageNamed: "BG1")
        background2.anchorPoint = CGPointMake(0.0, 0.5);
        //background2.setScale(scaleFactor)
        background2.position = CGPointMake(adjustmentBackgroundPosition - 1, self.size.height/2);
        background2.zPosition = 0;

        backgroundNode.addChild(background1)
        backgroundNode.addChild(background2)
        
        //  碰撞的部分
        let stone1 = SKSpriteNode(imageNamed: "blackStone")
        stone1.position = CGPointMake(0, -self.size.height/2)
        background1.addChild(stone1)
        
        let stone2 = SKSpriteNode(imageNamed: "blackStone")
        stone2.physicsBody = SKPhysicsBody(rectangleOfSize: stone1.size)
        stone2.position = CGPointMake(0, -self.size.height/2)
        background2.addChild(stone2)
        
        stone1.physicsBody = SKPhysicsBody(rectangleOfSize: stone1.size)
        stone1.physicsBody?.dynamic = false
        stone1.physicsBody?.categoryBitMask = CollisionCategoryBitmask.SeaBottom
        
        stone2.physicsBody = SKPhysicsBody(rectangleOfSize: stone1.size)
        stone2.physicsBody?.dynamic = false
        stone2.physicsBody?.categoryBitMask = CollisionCategoryBitmask.SeaBottom
        
    }
    
    // 滚动Enemy 层
    
    
    
    //MARK: 滚动背景层
    func scrollBackground() {
        adjustmentBackgroundPosition--
        if (adjustmentBackgroundPosition <= 0) {
            adjustmentBackgroundPosition = CGFloat(self.size.width)
        }
        
        background1.position = CGPointMake(CGFloat(adjustmentBackgroundPosition - CGFloat(self.size.width)), Screen_Height/2)
        background2.position = CGPointMake(CGFloat(adjustmentBackgroundPosition - 1), Screen_Height/2)
    }
    
    //MARK: 碰撞检测
    func didBeginContact(contact: SKPhysicsContact) {
        
        if !isGameOver {
            
            let other = (contact.bodyA.categoryBitMask == CollisionCategoryBitmask.Player ? contact.bodyB : contact.bodyA)
            
            switch other.categoryBitMask {
            case CollisionCategoryBitmask.Star:
                let starNode = other.node as! StarNode
                collisionWithStar(starNode)
                
            case CollisionCategoryBitmask.Enemy:
                let enemyNode = other.node
                collisionWithEnemy(enemyNode!)
                
            case CollisionCategoryBitmask.SeaBottom :
                collisionSeaBottom(playerNode)
                
            default:
                break;
            }
            
        }
    }
    
    override func didSimulatePhysics() {
        
    }
    
    
    //MARK: 碰撞结果执行
    func collisionWithStar(node:StarNode) {
        let musicOn = GameState.sharedInstance.musicState
        if musicOn {
            runAction(starSound, completion: { () -> Void in
                node.removeFromParent()
            })
        } else {
            node.removeFromParent()
        }
        
        showParticlesForGold(node)
        
        GameState.sharedInstance.stars += 1
        updateHUD()
       
    }
    
    func collisionWithEnemy(node:SKNode) {
        let musicOn = GameState.sharedInstance.musicState
        if musicOn {
            runAction(enemySound)
            gameOver()
        } else {
            gameOver()
        }
        
        showParticlesForEnemy(node)
        self.playerNode.removeFromParent()
        
    }
    
    //  碰撞海底
    
    func collisionSeaBottom(node:SKNode) {
        let musicOn = GameState.sharedInstance.musicState
        if musicOn {
            runAction(enemySound)
            gameOver()
        } else {
            gameOver()
        }
        
        showParticlesForEnemy(node)
        //self.playerNode.removeFromParent()
        self.playerNode.physicsBody?.dynamic = false
    }
    
    //MARK: 粒子特效
    
    // 撞击敌人 死亡特效
    func showParticlesForEnemy(node: SKNode) {
        
        let emitter = SKEmitterNode.emitterNamed("EnemySplatter")
        emitter.particleTexture!.filteringMode = .Nearest
        emitter.position = node.position
        emitter.zPosition = 100
        
        emitter.runAction(SKAction.removeFromParentAfterDelay(0.4))
        addChild(emitter)
    }
    
    // 金币特效
    func showParticlesForGold(node: StarNode) {
        
        let emitter = SKEmitterNode.emitterNamed("GoldSplatter")
        emitter.particleTexture!.filteringMode = .Nearest
        emitter.position = node.position
        
        emitter.runAction(SKAction.removeFromParentAfterDelay(0.4))
        addChild(emitter)
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
        starsLabel.text = "\(GameState.sharedInstance.stars)"
        let scaleIn = SKAction.scaleTo(1.5, duration: 0.1)
        let scaleOut = SKAction.scaleTo(1, duration: 0.2)
        starsLabel.runAction(SKAction.sequence([scaleIn, scaleOut])) //starsLabel.yScale
        
    }

    func updateMovingExtent() {
        // 更新移动距离
        scoreLabel.text = "\(Int(movingExtent))"
    }
    
    
    //MARK: 构建游戏Node
    //  动态创建敌人
    func createEnemy() {
        
        if !isGameOver {
            
            let randomEnemyX = CGFloat.random(Int(self.size.width) +  20 )
            
            self.enemyNode = self.creatEnemyformPosition(CGPointMake(randomEnemyX, self.playableRect.size.height + 50), ofType: self.enemyTypeLeve)
            
            let node = self.enemyNode as! EnemyNode
            self.addChild(node)
            
            let targetPostion = -self.playableRect.size.height + 50
            let bornPostion = self.playableRect.size.height + 50
            
            let totaltime:NSTimeInterval = NSTimeInterval((bornPostion - targetPostion) / enemySpeed)
            
            if node.enemyType == EnemyType.Normal {
                // 普通敌人
                let actionMove = SKAction.moveToY(-self.playableRect.size.height + 50, duration: totaltime * NSTimeInterval(enemySpeedLeve))
                let actionMoveDone = SKAction.removeFromParent()
                
                node.runAction(SKAction.sequence([actionMove, actionMoveDone]))
                
            } else if node.enemyType == EnemyType.SpecialRotate {
                // 旋转敌人
                let actionMove = SKAction.moveToY(-self.playableRect.size.height + 50, duration: totaltime * NSTimeInterval(enemySpeedLeve))
                let actionMoveDone = SKAction.removeFromParent()
                
                var actionRotate: SKAction!
                
                if self.rotateFlag {
                    // 逆时针旋转
                    actionRotate = SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.5)
                    
                } else {
                    // 顺时针旋转
                    actionRotate = SKAction.rotateByAngle(CGFloat(-M_PI), duration: 0.5)
                }
                
                let rotateAni = SKAction.repeatActionForever(actionRotate)
                
                let groupAni = SKAction.group([rotateAni, actionMove])
                
                node.runAction(SKAction.sequence([groupAni, actionMoveDone]))
                
                
                
            } else if node.enemyType == EnemyType.SpecialActive {
                // 移动敌人
                let actionMove = SKAction.moveToY(-self.playableRect.size.height + 50, duration: totaltime * NSTimeInterval(enemySpeedLeve))
                
                let actionMoveDone = SKAction.removeFromParent()
                var actionMoveByself = SKAction()
                
                if node.position.x <= self.playableRect.size.width/2 {
                    actionMoveByself = SKAction.moveToX(CGRectGetMaxX(self.playableRect), duration: totaltime * NSTimeInterval(enemySpeedLeve))
                    node.runAction(actionMove)
                } else if node.position.x >= self.playableRect.size.width/2 {
                    actionMoveByself = SKAction.moveToX(CGRectGetMinX(self.playableRect), duration: totaltime * NSTimeInterval(enemySpeedLeve))
                    node.runAction(actionMove)
                }
                
                let moveAni = SKAction.repeatActionForever(actionMoveByself)
                
                let groupAni = SKAction.group([moveAni, actionMove])
                
                node.runAction(SKAction.sequence([groupAni, actionMoveDone]))
                
                
            } else if node.enemyType == EnemyType.SpecialHidden {
                // 隐身敌人
                let actionMove = SKAction.moveToY(-self.playableRect.size.height + 50, duration: totaltime * NSTimeInterval(enemySpeedLeve))
                
                let actionMoveDone = SKAction.removeFromParent()
                
                let actionHidden = SKAction.fadeAlphaTo(CGFloat(0.2), duration: 0.5)
                
                let groupAni = SKAction.group([actionHidden, actionMove])
                
                node.runAction(SKAction.sequence([groupAni, actionMoveDone]))
                
            }
            
        }
        
    }
    
    
    // 构建障碍物
    func createBarrier() {
        
        let randomEnemyY = CGFloat.random(Int(self.size.height) +  20 )
        
        let node = SKNode()
        node.position = CGPointMake(Screen_Width * 1.5, randomEnemyY)
        node.zPosition = 50
        addChild(node)
        
        let bow = SKSpriteNode(imageNamed: "enemy")
        node.addChild(bow)
        
        node.physicsBody = SKPhysicsBody(rectangleOfSize: bow.size)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = 0
        
        
        let move = SKAction.moveToX(-Screen_Width/2, duration: 3)
        let movedone = SKAction.removeFromParent()
        node.runAction(SKAction.sequence([move, movedone]))
        
    }
    
    
    //构建player
    func createPlayer() ->SKNode {
        
        let node = SKNode()
        node.position = CGPoint(x: Screen_Width/3, y: self.size.height/2)
        
        let submarineSp = SKSpriteNode(imageNamed: "submarine")
        node.addChild(submarineSp)

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
        
        node.physicsBody = SKPhysicsBody(rectangleOfSize: submarineSp.size)
        node.physicsBody?.dynamic = false
        node.physicsBody?.allowsRotation = false
        
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Enemy | CollisionCategoryBitmask.SeaBottom
        
        return node
    }
    
    // 创建敌人
    func creatEnemyformPosition(position: CGPoint, ofType type: EnemyType) ->EnemyNode {
        
        let _node = EnemyNode()
        _node.name = "enemyNode"
        
        // 随机位置
        _node.position = CGPoint(x: position.x, y: position.y )
        _node.enemyType = type
        
        let sprite = SKSpriteNode(imageNamed: "enemy")
        _node.addChild(sprite)
        
        _node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        
        return _node
        
    }
    
    // 创建星星
    func createStar() {
        if !isGameOver {
            
            let _node = StarNode()
            
            let randomEnemyX = CGFloat.random(Int(Screen_Width) + 20)
            
            // 随机位置
            _node.position = CGPoint(x: randomEnemyX, y: playableRect.size.height + 50)
            
            if _node.position.x < CGRectGetMinX(playableRect) {
                _node.position.x = randomEnemyX + 20
            }
            
            if _node.position.x > CGRectGetMinX(playableRect) {
                _node.position.x = randomEnemyX - 20
            }
            
            let sprite = SKSpriteNode(imageNamed: "Star")
            _node.addChild(sprite)
            
            
            _node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
            _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
            
            addChild(_node)
            
            //
            let targetPostion = -self.playableRect.size.height + 50
            let bornPostion = self.playableRect.size.height + 50
            
            // 移动的速度
            let totaltime:NSTimeInterval = NSTimeInterval((bornPostion - targetPostion) / starSpeed)
            
            let actionMove = SKAction.moveToY(-playableRect.size.height + 50, duration: totaltime)
            let actionMoveDone = SKAction.removeFromParent()
            
            _node.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
        
    }

    //MARK: 开始游戏
    func starGame() {
        isGameOver = false
        isGameBegin = true
        
        playerNode.physicsBody?.dynamic = true
        
        self.pauseButton.hidden = false
        
        homePageUINode.removeFromParent()
        guideFigerNode.removeFromParent()
        homePageBottomButtonsNode.removeFromParent()
        
        showGameSceneUI()
        
        // 2. 游戏开始后的音乐
        let music = GameState.sharedInstance.musicState
        if music {
            // 播放音乐
            SKTAudio.sharedInstance().playBackgroundMusic("game_music2.mp3")
        }
        
        createGameNodes()
        
    }
    
    //MARK:  暂停游戏
    func pauseGame() {
        showGamePauseUI()
        // 1 游戏暂停
        //gamePause = true
        
        pauseButton.hidden = true
        
        // 2 保存游戏分数和进度
        GameState.sharedInstance.saveState()
        
        self.paused = true
        
    }
    
    //MARK: 继续游戏
    func continueGame() {
        self.view?.paused = false
        //gamePause = false
        
        pauseButton.hidden = false
        
        pauseUINode.removeFromParent()
    }
    
    //MARK: 游戏结束
    func gameOver() {
        isGameBegin = false
        self.isGameOver = true
        self.pauseButton.removeFromParent()
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        
        // 保存游戏状态 分数等信息
        GameState.sharedInstance.movingScore = Int(movingExtent)
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
        scoreLabel.position = CGPoint(x:10 , y: self.size.height-80)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.text = "\(Int(movingExtent))" //"0 M"
        gameSceneUINode.addChild(scoreLabel)
        
        // 金币图标
        let staricon = SKSpriteNode(imageNamed: "Star")
        staricon.position = CGPoint(x: 25, y: self.size.height-30)
        staricon.setScale(0.8)
        gameSceneUINode.addChild(staricon)
        
        // 金币数量
        starsLabel = SKLabelNode(fontNamed: font_Name)
        starsLabel.fontSize = 24
        starsLabel.fontColor = SKColor.whiteColor()
        starsLabel.position = CGPoint(x: 50, y: self.size.height-40)
        starsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        starsLabel.text = String(format: "%d", GameState.sharedInstance.stars)
        gameSceneUINode.addChild(starsLabel)
        
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
        
        println("showiAd")
        
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
        label.text = "SHOW iAd"
        label.position = CGPointMake(-Screen_Width/2, 0)
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
        starsLabel.text = String(format: "%d", GameState.sharedInstance.stars)
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
        scoreTotalLabel.text = String(format: "收集金币: %d", GameState.sharedInstance.stars)
        overUINode.addChild(scoreTotalLabel)
        
        let distanceLabel = SKLabelNode(fontNamed: font_Name)
        distanceLabel.position = CGPointMake(0, -40)
        distanceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        distanceLabel.text = String(format: "飞行距离: %d", GameState.sharedInstance.movingScore)
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
        
        self.paused = false
        pauseUINode.removeFromParent()
        pauseButton.hidden = false
        
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
        // 游戏开始前的设置
        
        if !isGameOver && !isOpenUI {
            
            let touch = touches.first as! UITouch
            let locationInNode = touch.locationInNode(self)

            let tagetPoint:CGPoint = locationInNode
            let playerPoint:CGPoint = playerNode.position
            
            let moveTime = playMovingTime(playerPoint, p2: tagetPoint, speed: Player_Move_Speed)
            
            println("Player_Move_Speed :\(Player_Move_Speed)")
            
            if isFristRuning {
                starGame()
                isFristRuning = false
            }
            
            
            //playerNode.runAction(SKAction.moveTo(locationInNode, duration: Double(moveTime)))
            tapEffectsForTouchAtLocation(locationInNode)
            
            playerNode.physicsBody?.velocity = CGVectorMake(0, 0)
            playerNode.physicsBody?.applyImpulse(CGVectorMake(0, 100))
        }
        
    }

    
    var lastSpawnTimeInterval:NSTimeInterval  = 0// 上次更新时间
    var lastUpdateTimeInterval: NSTimeInterval = 0
    
    override func update(currentTime: CFTimeInterval) {
        if isGameBegin {
            scrollBackground()
        }
        
//        if isGameBegin {
//            playTime++
//            movingExtent = Int(self.playTime * playerMoveSpeed)
//            updateMovingExtent()
//        }
        
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
}


// MARK: - Extensions

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension SKColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return SKColor.brownColor()
        case 1: return SKColor.blueColor()
        case 2: return SKColor.orangeColor()
        case 3: return SKColor.magentaColor()
        case 4: return SKColor.purpleColor()
        default: return SKColor.purpleColor()
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




