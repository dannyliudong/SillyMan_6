//
//  GameScene.swift
//  TinyWings
//
//  Created by liudong on 15/5/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//
import SpriteKit

@objc protocol GamePlayDelegate {
    //func gameTryAgain()
    func gameGoHome()
}

class UnionModeGameScene: SKScene, SKPhysicsContactDelegate, EnemyCollisionWithPlayerDelegate {

    var gamePlaydelegate:GamePlayDelegate!
    
    // MARK: Properties
    
    // To Accommodate iPhone 6
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
            print(".........movingExtent: \(self.movingExtent)")
        }
    }
    
    var guideFigerNode: SKNode! // 指引手指
    
    //MARK: Private Properties
    //  得分
    //private var scoreTotal:Int = 0
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
    private var isPlayerMoveDone = false
    private var isTryAgainGame = false
    private var isOpenUI = false // 是否在主页打开了某些界面 如果打开了 游戏不会开始
    
    private var scoreLabel: SKLabelNode!
    private var starsLabel: SKLabelNode!
    private var staricon: SKSpriteNode!
    
    private var backgroundNode: SKNode!
    private var background1:SKNode!
    private var background2:SKNode!
    
    private var adjustmentBackgroundPosition = 0 //调整背景位置
    
    //MARK: 初始化
    override init(size: CGSize) {
        super.init(size: size)
        
        scaleFactor = self.size.width / 320.0
        
        self.playableRect = CGRect(x: 0, y: 0 , width: size.width, height: size.height)
        
        self.backgroundColor = SKColor.random
        
        enemyTypeLeve = EnemyType.Normal
        enemySpeedLeve = 1
        
        // 粒子背景
//        let particlePath = NSBundle.mainBundle().pathForResource("Bokeh", ofType: "sks")
//        let emitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(particlePath!) as! SKEmitterNode
//        emitterNode.position = CGPointMake(self.size.width/2, self.size.height/2)
//        emitterNode.alpha = 0.5
//        addChild(emitterNode)
//        emitterNode.hidden = true
        
        
        // 引导手指
        figerNode()
        guideFigerNode.hidden = false
        
        // 暂停控制按钮
        pauseButton = SKSimpleButton(imageNamed: "button-pause")
        pauseButton.zPosition = 60
        pauseButton.name = "pauseButton"
        pauseButton.targetTouchUpInside = self
        pauseButton.actionTouchUpInside = "pauseGame" // 执行方法名
        pauseButton.size = CGSize(width: Button_Width/1.5, height: Button_Width/1.5)
        pauseButton.position = CGPointMake(self.size.width - Button_Width / 2, self.size.height - Button_Width / 2)
        pauseButton.hidden = true
        addChild(pauseButton)
        
        // 创建主页UI
        if !isTryAgainGame {
            openHomePageUI()
        }
        
        isFristRuning = true
        isGameOver = false
        
        initPhysicsWorld()
        
        self.playerNode = createPlayer()
        addChild(playerNode)
        
        playerFirstAction() // 角色出场动画
        
        //createBackground()
        
        //  1.游戏开始前的音乐
        SKTAudio.sharedInstance().playBackgroundMusic("night_1_v3.mp3")

        let micON = GameState.sharedInstance.musicState
        if !micON {
            SKTAudio.sharedInstance().pauseBackgroundMusic()
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Did Move To View
    override func didMoveToView(view: SKView) {
        
    }
    
    func createGameNodes() {
        //  游戏开始后, 等待1秒开始生成敌人和星
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(createEnemy),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.waitForDuration(5.0),
                SKAction.runBlock(createStar)])
            ))
    }
    
    func initPhysicsWorld() {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        //self.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Edge

    }
    
    var rotateFlag:Bool = true // 旋转方向 true: 逆时针方向， false:  顺时针方向
    
    //  角色进场动画
    func playerFirstAction() {
        
        let playerPoint = CGPoint(x: self.size.width/2, y: self.size.height/3)
        let palyerFistAction = SKAction.moveTo(playerPoint, duration: 0.5)
        palyerFistAction.timingMode = SKActionTimingMode.EaseIn
        
        let moveDone = SKAction.runBlock { () -> Void in
            self.isPlayerMoveDone = true
        }
        self.playerNode.runAction(SKAction.sequence([palyerFistAction, moveDone]))
        
    }
    
    //  引导手指
    func figerNode() {
        guideFigerNode = SKNode()
        guideFigerNode.xScale = 0.6
        guideFigerNode.yScale = 0.6
        
        guideFigerNode.zPosition = 50
        guideFigerNode.position = CGPoint(x: self.size.width/2, y: self.size.height/8)
        addChild(guideFigerNode)
        
        let fingerSprite = SKSpriteNode(texture: atlas.finger_finger01())
        guideFigerNode.addChild(fingerSprite)
        
        let fingerTouch = SKAction.animateWithTextures(atlas.finger_finger(), timePerFrame: 0.3)
        let fingerTouchAni = SKAction.repeatAction(fingerTouch, count: 6)
        let fingerTouchSequence = SKAction.repeatActionForever(SKAction.sequence([fingerTouchAni]))
        fingerSprite.runAction(fingerTouchSequence)
    }

    
    //var lastEnemyType = EnemyType.SpecialRotate
    

    

    //MARK: 创建背景层
    func createBackground() {
        background1 = SKNode()
        background2 = SKNode()
        addChild(background1)
        addChild(background2)
        
        // 生成背景
        
        let bgsp1 = SKSpriteNode(color: SKColor.blueColor(), size: self.size)
        let bgsp2 = SKSpriteNode(color: SKColor.blueColor(), size: self.size)
        
        background1.addChild(bgsp1)
        background2.addChild(bgsp2)
        
        
    }
    
    //MARK: 滚动背景
    func scrollBackground() {
        adjustmentBackgroundPosition--
        if (adjustmentBackgroundPosition <= 0) {
            adjustmentBackgroundPosition = Int(self.size.height)
        }
        
        background1.position = CGPointMake(self.size.width/2, CGFloat(adjustmentBackgroundPosition - Int(self.size.height)))
        background2.position = CGPointMake(self.size.width/2, CGFloat(adjustmentBackgroundPosition - 1))
    }
    
    //MARK: 碰撞检测
    func didBeginContact(contact: SKPhysicsContact) {
        
        if !isGameOver {
            var updateHUD = false
            let whichNode = (contact.bodyA.node != playerNode) ? contact.bodyA.node : contact.bodyB.node
            let other = whichNode as! GameObjectNode
            updateHUD = other.collisionWithPlayer(playerNode)
            
            if updateHUD {
                starTotal = GameState.sharedInstance.stars
                starsLabel.text = "\(GameState.sharedInstance.stars)"
            }
        }
    }
    
    
    //MARK: 构建游戏Node
    //  动态创建敌人
    func createEnemy() {
        
        if !isGameOver {
            
            let randomEnemyX = CGFloat.random(Int(self.size.width) +  20 )
            
            self.enemyNode = self.creatEnemyformPosition(CGPointMake(randomEnemyX, self.playableRect.size.height + 50), ofType: self.enemyTypeLeve)
            
            let node = self.enemyNode as! EnemyNode
            node.delegate = self
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
    
    //构建player
    func createPlayer() ->SKNode {
        
        let _node = SKNode()
        _node.xScale = 0.5
        _node.yScale = 0.5
        
        _node.position = CGPoint(x: self.size.width/2, y: -self.size.height)

        let smileSprite = SKSpriteNode(texture: atlas.face_1_face_1_001())
        _node.addChild(smileSprite)
        
        let smile = SKAction.animateWithTextures(atlas.face_1_face_1_(), timePerFrame: 0.1)
        let smileAni = SKAction.repeatAction(smile, count: 6)
        let smileSequence = SKAction.repeatActionForever(SKAction.sequence([smileAni]))
        smileSprite.runAction(smileSequence)
    
        
        let tentaclesSprite = SKSpriteNode(texture: atlas.tentacles_tentacles_1())
        tentaclesSprite.yScale = 0.8
        tentaclesSprite.xScale = 0.8
        tentaclesSprite.position = CGPointMake(tentaclesSprite.size.width/3, -tentaclesSprite.size.height/1.5)
        smileSprite.addChild(tentaclesSprite)
        
        let tentacles = SKAction.animateWithTextures(atlas.tentacles_tentacles_(), timePerFrame: 0.033)
        let tentaclesAni = SKAction.repeatAction(tentacles, count: 6)
        let tentaclesSequence = SKAction.repeatActionForever(SKAction.sequence([tentaclesAni]))
        tentaclesSprite.runAction(tentaclesSequence)
        
        _node.physicsBody = SKPhysicsBody(circleOfRadius: smileSprite.size.width/2 * 0.5)
        _node.physicsBody?.dynamic = false
        _node.physicsBody?.allowsRotation = false
        _node.physicsBody?.usesPreciseCollisionDetection = true
        
        _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        _node.physicsBody?.collisionBitMask = 0//CollisionCategoryBitmask.Star
        _node.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Enemy
        
        return _node
    }
    
    // 创建敌人
    func creatEnemyformPosition(position: CGPoint, ofType type: EnemyType) ->EnemyNode {
        
        let _node = EnemyNode()
        
        // 随机位置
        _node.position = CGPoint(x: position.x, y: position.y )
        _node.enemyType = type
        
        let sprite = SKSpriteNode(imageNamed: "enemy")
        
        _node.addChild(sprite)
        
        _node.zPosition = 1
        
        _node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        _node.physicsBody?.dynamic = true
        
        _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        _node.physicsBody?.collisionBitMask = 0//CollisionCategoryBitmask.Player
        _node.physicsBody?.contactTestBitMask = 0//CollisionCategoryBitmask.Player
        
        _node.delegate = self
        //addChild(_node)
        
        return _node
        
    }
    
    // 创建星星
    func createStar() {
        if !isGameOver {
            
            let _node = StarNode()
            
            let randomEnemyX = CGFloat.random(Int(self.size.width) + 20)
            
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
            
            _node.zPosition = 1
            
            _node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
            
            _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
            _node.physicsBody?.collisionBitMask = 0//CollisionCategoryBitmask.Player
            _node.physicsBody?.contactTestBitMask = 0//CollisionCategoryBitmask.Player
            
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
    
    //MARK: 难度等级控制
    
    let speedLeve1 = CGFloat(1.0)
    let speedLeve2 = CGFloat(0.8)
    let speedLeve3 = CGFloat(0.6)
    
    func gameLeveDataControlle() {
        
        //  等级选择
        let leveOp:Int = Int(movingExtent)
        print("leveOp : \(leveOp)")
        
        if leveOp < 100 {
            if leveOp == 50 {
                self.enemySpeedLeve = self.speedLeve2
            }
            
        } else if leveOp >= 100 && leveOp < 300 {
            switch leveOp {
            case 100:
                self.showSuccessMark()
                self.enemySpeedLeve = self.speedLeve1
            case 110:
                self.enemyTypeLeve = EnemyType.SpecialRotate
            case 200:
                self.enemySpeedLeve = self.speedLeve2
            case 300:
                self.enemySpeedLeve = self.speedLeve3
            default:
                return
            }
            
        } else if leveOp >= 30 && leveOp < 60 {
            
            switch leveOp {
            case 20:
                self.showSuccessMark()
                self.enemySpeedLeve = self.speedLeve1
            case 21:
                self.enemyTypeLeve = EnemyType.SpecialActive
            case 30:
                self.enemySpeedLeve = self.speedLeve2
            case 50:
                self.enemySpeedLeve = self.speedLeve3
            default:
                return
            }
            
        } else if leveOp >= 60 && leveOp < 100 {
            
            switch leveOp {
            case 60:
                self.showSuccessMark()
                self.enemySpeedLeve = self.speedLeve1
            case 61:
                self.enemyTypeLeve = EnemyType.SpecialHidden
            case 70:
                self.enemySpeedLeve = self.speedLeve2
            case 90:
                self.enemySpeedLeve = self.speedLeve3
            default:
                return
            }


        } else if leveOp > 100 {
            
            switch leveOp {
            case 100:
                self.showSuccessMark()
                self.enemySpeedLeve = self.speedLeve1
            case 101:
                EnemyType.randomEnemyType()
            case 120:
                self.enemySpeedLeve = self.speedLeve2
            case 200:
                self.enemySpeedLeve = self.speedLeve3
            default:
                return
            }

        }
        
    }
    
    func gameLeveDataControlle(distance:CGFloat, leve:Int) {
        
    }
    
    
    // 显示达成成就
    func showSuccessMark() {
        
        print("showSuccessMark xxxxxxxxxx ")
        
        let markNode = SKNode()
        markNode.position = CGPointMake(self.size.width/2, self.size.height/2)
        markNode.zPosition = 60
        markNode.alpha = 0
        addChild(markNode)
        
        let showlabel = SKLabelNode(fontNamed: "HelveticaNeue")
        showlabel.fontSize = 24

        showlabel.text = "👾怪兽来了👾"
        markNode.addChild(showlabel)
        
        // 动画
        //let palyerFistAction = SKAction.scaleTo(2.0, duration: 0.2)
        //palyerFistAction.timingMode = SKActionTimingMode.EaseInEaseOut
        let fadeAlpha = SKAction.fadeAlphaTo(0.5, duration: 0.2)
        
        //markNode.runAction(SKAction.group([palyerFistAction, fadeAlpha]))
        
        let wait = SKAction.waitForDuration(0.5)
        let doneAni = SKAction.removeFromParent()
        
        markNode.runAction(SKAction.sequence([fadeAlpha, wait, doneAni]))
        
        //runAction(SKAction.sequence([fadeAlpha, wait]))
        
    }
    
    // 游戏进度控制
//    func gameLeveControlle() ->(type:EnemyType, speed:CGFloat) {
//        // 游戏开始 进入Leve1
//        // 游戏一定时间后 进入Leve2
//        // 游戏一定时间后 进入Leve3 依此类推
//        
//        // Leve1 普通敌人, 慢速, -> 中速 ->  快速
//        // Leve2 旋转敌人, 慢速, -> 中速 ->  快速
//        // Leve3 移动敌人, 慢速, -> 中速 ->  快速
//        // Leve4 隐身敌人, 慢速, -> 中速 ->  快速
//        // Leve5 随机敌人, 慢速, -> 中速 ->  快速
//        
//        let gameleve:Int = 1 // (敌人等级1-)
//        let emenySpeed:UInt8 = 1 // (速度等级 1－3)
//        
//        let speedLeve1 = CGFloat(1.0)
//        let speedLeve2 = CGFloat(0.6)
//        let speedLeve3 = CGFloat(0.3)
//        
//        // Leve1
//        if gameleve == 1 && emenySpeed == 1 {
//            return (EnemyType.Normal, speedLeve1)
//        }
//        if gameleve == 1 && emenySpeed == 2 {
//            return (EnemyType.Normal, speedLeve2)
//        }
//        if gameleve == 1 && emenySpeed == 3 {
//            return (EnemyType.Normal, speedLeve3)
//        }
//        
//        // Leve2
//        if gameleve == 2 && emenySpeed == 1 {
//            return (EnemyType.SpecialRotate, speedLeve1)
//        }
//        if gameleve == 2 && emenySpeed == 2 {
//            return (EnemyType.SpecialRotate, speedLeve2)
//        }
//        if gameleve == 2 && emenySpeed == 3 {
//            return (EnemyType.SpecialRotate, speedLeve3)
//        }
//        
//        // Leve3
//        if gameleve == 3 && emenySpeed == 1 {
//            return (EnemyType.SpecialActive, speedLeve1)
//        }
//        if gameleve == 3 && emenySpeed == 2 {
//            return (EnemyType.SpecialActive, speedLeve2)
//        }
//        if gameleve == 3 && emenySpeed == 3 {
//            return (EnemyType.SpecialActive, speedLeve3)
//        }
//        
//        // Leve4
//        if gameleve == 4 && emenySpeed == 1 {
//            return (EnemyType.SpecialHidden, speedLeve1)
//        }
//        if gameleve == 4 && emenySpeed == 2 {
//            return (EnemyType.SpecialHidden, speedLeve2)
//        }
//        if gameleve == 4 && emenySpeed == 3 {
//            return (EnemyType.SpecialHidden, speedLeve3)
//        }
//        
//        // Leve5
//        if gameleve == 5 && emenySpeed == 1 {
//            return (EnemyType.SpecialHidden, speedLeve1)
//        }
//        if gameleve == 5 && emenySpeed == 2 {
//            return (EnemyType.SpecialHidden, speedLeve2)
//        }
//        if gameleve == 5 && emenySpeed == 3 {
//            return (EnemyType.SpecialHidden, speedLeve3)
//        }
//        
//        return (EnemyType.Normal, speedLeve2)
//        
//    }
    
    
    //MARK: 开始游戏
    func starGame() {
        print("UnionModeScene -> starGame:", appendNewline: false)
        isGameOver = false
        isGameBegin = true
        
        self.pauseButton.hidden = false
        
        guideFigerNode.removeFromParent()
        
        //playerFirstAction() // 角色出场动画

        // 关闭主页UI
        closeHomePageUI()
        showGameSceneUI()
        
        // 2. 游戏开始后的音乐
        let micON = GameState.sharedInstance.musicState
        if micON {
            SKTAudio.sharedInstance().playBackgroundMusic("game_music2.mp3")
        }
        
        createGameNodes()
        
    }
    
    
    //MARK:  暂停游戏
    func pauseGame() {
        print("游戏暂停", appendNewline: false)

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
        print("暂停 ->继续游戏", appendNewline: false)
        self.view?.paused = false
        //gamePause = false
        
        pauseButton.hidden = false
        
        closePauseUI()
    }
    
    //MARK: 游戏结束
    func gameOver() {
        print("gameOver >>>>", appendNewline: true)
        isGameBegin = false
        self.isGameOver = true
        self.pauseButton.hidden = true
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        
        // 保存游戏状态 分数等信息
        
        GameState.sharedInstance.movingScore = Int(movingExtent)
        GameState.sharedInstance.saveState()
        
        self.playerNode.runAction(SKAction.moveToY(-100, duration: 0.5))
        
        //  用dispatch_after推迟任务
        let delayInSeconds = 0.5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.playerNode.removeFromParent()
            self.showGameOverUI()
        }
        
        self.gameSceneUINode.hidden = true

    }
    
    //MARK:界面控制
    
    // 打开设置
    func openSettingsPage() {
        closeHomePageUI()
        openSettingsUI()
        
        guideFigerNode.hidden = true
        
        isOpenUI = true
        
        print("打开设置")
    }
    
    // 关闭设置
    func closeSettingsPage() {
        openHomePageUI()
        
        guideFigerNode.hidden = false
        
        settingsUINode.removeFromParent()
        isOpenUI = false
    }
    
    // 打开分享
    func openSharePage() {
        print("打开分享")
        
    }
    
    // 显示游戏场景UI
    func showGameSceneUI() {
        print("showGameSceneUI ->>>")
        
        gameSceneUINode = SKNode()
        addChild(gameSceneUINode)
        
        // 飞行米数
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue")
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
        starsLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        starsLabel.fontSize = 24
        starsLabel.fontColor = SKColor.whiteColor()
        starsLabel.position = CGPoint(x: 50, y: self.size.height-40)
        starsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        starsLabel.text = String(format: "%d", GameState.sharedInstance.stars)
        gameSceneUINode.addChild(starsLabel)
        
        //
        
    }
    
    // 打开设置UI
    func openSettingsUI() {
        settingsUINode = SKNode()
        settingsUINode.position = CGPointMake(self.size.width/2, self.size.height/2)
        settingsUINode.zPosition = 60
        addChild(settingsUINode)
        
        // 遮罩
        let maskSprite = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        maskSprite.alpha = 0.8
        settingsUINode.addChild(maskSprite)
        
        // 关闭
        let closeButton = SKSimpleButton(imageNamed: "button-quit-on")
        closeButton.name = "gohomeButton"
        closeButton.targetTouchUpInside = self
        closeButton.actionTouchUpInside = "closeSettingsPage" // 执行方法名
        closeButton.size = CGSize(width: 60, height: 60)
        closeButton.position = CGPointMake(-self.size.width/2 + closeButton.size.width/1.5, self.size.height/2 - closeButton.size.height/1.5)
        settingsUINode.addChild(closeButton)
        
        // 语言
        
        let languageButton = SKSimpleButton(imageNamed: "setButtonbg")
        languageButton.name = "gohomeButton"
        languageButton.targetTouchUpInside = self
        languageButton.actionTouchUpInside = "languageButtonAction" // 执行方法名
        //languageButton.size = setButtonbgimage.size
        languageButton.position = CGPointMake(0, 100)
        settingsUINode.addChild(languageButton)
        
        let languageLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        languageLabel.fontSize = 20
        languageLabel.position = CGPointMake(0, -8)
        languageLabel.text = String(format: "语言")
        languageButton.addChild(languageLabel)

        // 音乐控制按钮
        musicButton = SKSimpleButton(imageNamed: "setMusic")
        musicButton.name = "gohomeButton"
        musicButton.targetTouchUpInside = self
        musicButton.actionTouchUpInside = "musicButtonAction" // 执行方法名
        //musicButton.size = setButtonbgimage.size
        musicButton.position = CGPointMake(0, 50)
        
        let isON:Bool = GameState.sharedInstance.musicState
        if !isON {
            self.musicButton.alpha = 0.8
            self.musicButton.color = SKColor.whiteColor()
        } else {
            self.musicButton.alpha = 1
            self.musicButton.color = SKColor.clearColor()
        }
        settingsUINode.addChild(musicButton)
        
//        let musicLabel = SKLabelNode(fontNamed: "HelveticaNeue")
//        musicLabel.fontSize = 20
//        musicLabel.position = CGPointMake(0, -8)
//        musicLabel.text = String(format: "音乐")
//        musicButton.addChild(musicLabel)
        
//        // 音效控制按钮
//        soundButton = SKSimpleButton(imageNamed: "setButtonbg")
//        soundButton.name = "gohomeButton"
//        soundButton.targetTouchUpInside = self
//        soundButton.actionTouchUpInside = "soundButtonAction" // 执行方法名
//        //soundButton.size = setButtonbgimage.size
//        soundButton.position = CGPointMake(0, 0)
//        settingsUINode.addChild(soundButton)
//        
//        let soundLabel = SKLabelNode(fontNamed: "HelveticaNeue")
//        soundLabel.fontSize = 20
//        soundLabel.position = CGPointMake(0, -8)
//        soundLabel.text = String(format: "音效")
//        soundButton.addChild(soundLabel)
        
        // 界面动画
//        let palyerFistAction = SKAction.moveToY(self.size.height/1.5, duration: 0.3)
//        palyerFistAction.timingMode = SKActionTimingMode.EaseInEaseOut
//        let fadeAlpha = SKAction.fadeAlphaTo(1, duration: 0.2)
//        settingsUINode.runAction(SKAction.group([palyerFistAction, fadeAlpha]))
    }
    
    //  显示主页UI
    func showHomePageUI() {
        print("显示主页UI ->>>")
        
        homePageUINode = SKNode()
        homePageUINode.zPosition = 50
        addChild(homePageUINode)
        
        // 设置按钮
        let settingsButton = SKSimpleButton(imageNamed: "button-settings-on")
        settingsButton.name = "settingsButton"
        settingsButton.targetTouchUpInside = self
        settingsButton.actionTouchUpInside = "openSettingsPage" // 执行方法名
        settingsButton.size = CGSize(width: Button_Width, height: Button_Width)
        settingsButton.position = CGPointMake(Button_Width/1.5, 40)
        homePageUINode.addChild(settingsButton)
        
        // 分享按钮
        let shareButton = SKSimpleButton(imageNamed: "button-share-on")
        shareButton.name = "shareButton"
        shareButton.targetTouchUpInside = self
        shareButton.actionTouchUpInside = "openSharePage" // 执行方法名
        shareButton.size = CGSize(width: Button_Width, height: Button_Width)
        shareButton.position = CGPointMake(self.size.width - Button_Width/1.5, 40)
        homePageUINode.addChild(shareButton)
        
        // 分数榜
        let logoSprite = SKSpriteNode(imageNamed: "logoTitleSp")
        logoSprite.position = CGPointMake(self.size.width/2, self.size.height - 80)
        homePageUINode.addChild(logoSprite)
        
        let highScoreLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        highScoreLabel.fontSize = 26
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
        starsLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        starsLabel.fontSize = 30
        starsLabel.fontColor = SKColor.whiteColor()
        starsLabel.position = CGPoint(x: 50, y: self.size.height-40)
        starsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        starsLabel.text = String(format: "%d", GameState.sharedInstance.stars)
        homePageUINode.addChild(starsLabel)
        
//        let wordLabel = SKLabelNode(fontNamed: "HelveticaNeue")
//        wordLabel.fontSize = 26
//        wordLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/16)
//        wordLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
//        wordLabel.text = "轻按来开始"
//        homePageUINode.addChild(wordLabel)
        
    }
    
    // 显示暂停界面
    func showGamePauseUI() {
        
        print("showGamePauseUI ->>>")
        
        pauseUINode = SKNode()
        pauseUINode.zPosition = 60
        pauseUINode.position = CGPointMake(self.size.width/2, self.size.height/2)
        addChild(pauseUINode)
        
        // 遮罩
        let maskSprite = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        maskSprite.alpha = 0.3
        pauseUINode.addChild(maskSprite)
        
        // 回主页按钮
        let gohomeButton = SKSimpleButton(imageNamed: "button-quit-on")
        gohomeButton.name = "gohomeButton"
        gohomeButton.targetTouchUpInside = self
        gohomeButton.actionTouchUpInside = "pauseGoHome" // 执行方法名
        gohomeButton.size = CGSize(width: Button_Width, height: Button_Width)
        gohomeButton.position = CGPointMake(-self.size.width/4, -self.size.height/5)
        pauseUINode.addChild(gohomeButton)
        
        // 继续按钮
        let continueButton = SKSimpleButton(imageNamed: "button-continue")
        continueButton.name = "continueButton"
        continueButton.targetTouchUpInside = self
        continueButton.actionTouchUpInside = "pauseContinue" // 执行方法名
        continueButton.size = CGSize(width: Button_Width, height: Button_Width)
        continueButton.position = CGPointMake(self.size.width/4, -self.size.height/5)
        pauseUINode.addChild(continueButton)
        
        // 重玩按钮
//        let tryAgainButton = SKSimpleButton(imageNamed: "button-retry-on")
//        tryAgainButton.name = "tryAgainButton"
//        tryAgainButton.targetTouchUpInside = self
//        tryAgainButton.actionTouchUpInside = "pauseTryAgain" // 执行方法名
//        tryAgainButton.size = CGSize(width: Button_Width, height: Button_Width)
//        tryAgainButton.position = CGPointMake(self.size.width/3, -self.size.height/5)
//        pauseUINode.addChild(tryAgainButton)
        
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
        
        let scoreTotalLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        scoreTotalLabel.position = CGPointMake(0, 0)
        scoreTotalLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreTotalLabel.text = String(format: "收集金币: %d", GameState.sharedInstance.stars)
        overUINode.addChild(scoreTotalLabel)
        
        let distanceLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        distanceLabel.position = CGPointMake(0, -40)
        distanceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        distanceLabel.text = String(format: "飞行距离: %d", GameState.sharedInstance.movingScore)
        overUINode.addChild(distanceLabel)
        
        let scoreHigthLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        scoreHigthLabel.position = CGPointMake(0, -80)
        scoreHigthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreHigthLabel.text = String(format: "最高纪录: %d", GameState.sharedInstance.highScore)
        overUINode.addChild(scoreHigthLabel)
        
        // 回主页按钮
        let gohomeButton = SKSimpleButton(imageNamed: "button-home-on")
        gohomeButton.name = "gohomeButton"
        gohomeButton.targetTouchUpInside = self
        gohomeButton.actionTouchUpInside = "gameOverGoHome" // 执行方法名
        gohomeButton.size = CGSize(width: Button_Width, height: Button_Width)
        gohomeButton.position = CGPointMake(-80, -200)
        overUINode.addChild(gohomeButton)

        // 重试按钮
        let tryAgainButton = SKSimpleButton(imageNamed: "button-retry-on")
        tryAgainButton.name = "gohomeButton"
        tryAgainButton.targetTouchUpInside = self
        tryAgainButton.actionTouchUpInside = "gameOverTryAgain" // 执行方法名
        tryAgainButton.size = CGSize(width: Button_Width, height: Button_Width)
        tryAgainButton.position = CGPointMake(80, -200)
        overUINode.addChild(tryAgainButton)
        
        // 界面动画
        let palyerFistAction = SKAction.moveToY(self.size.height/1.5, duration: 0.3)
        palyerFistAction.timingMode = SKActionTimingMode.EaseInEaseOut
        let fadeAlpha = SKAction.fadeAlphaTo(1, duration: 0.2)
        overUINode.runAction(SKAction.group([palyerFistAction, fadeAlpha]))
        
    }
    
    // 打开主页UI
    func openHomePageUI() {
        print("关闭主页UI ->>>", appendNewline: true)
        showHomePageUI()
    }
    
    // 关闭主页UI
    func closeHomePageUI() {
        print("关闭主页UI ->>>", appendNewline: true)
        
        homePageUINode.hidden = true
        
    }
    
    // 关闭暂停游戏界面
    func closePauseUI() {
        print("关闭暂停游戏界面", appendNewline: true)
        pauseUINode.removeFromParent()
        
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
        print("选择语言", appendNewline: true)
    }
    
    // 音乐开关
    func musicButtonAction() {
        print("音乐开关", appendNewline: true)

        let isON:Bool = GameState.sharedInstance.musicState
        if isON {
            // 如果是开的 就暂停音乐
            self.musicButton.alpha = 0.5
            self.musicButton.color = SKColor.whiteColor()
            
            SKTAudio.sharedInstance().pauseBackgroundMusic()
            GameState.sharedInstance.musicState = false
            GameState.sharedInstance.soundEffectState = false
            GameState.sharedInstance.saveState()
            
        } else {
            // 恢复音乐播放
            
            self.musicButton.alpha = 1
            self.musicButton.color = SKColor.clearColor()
            
            SKTAudio.sharedInstance().resumeBackgroundMusic()
            GameState.sharedInstance.musicState = true
            GameState.sharedInstance.soundEffectState = true
            GameState.sharedInstance.saveState()
        }
        
        
    }
    
    // 音效
//    func soundButtonAction() {
//        print("音效开关", appendNewline: true)
//        
//        let isON:Bool = GameState.sharedInstance.soundEffectState
//        if isON {
//            // 如果是开的 就暂停音乐
//            GameState.sharedInstance.soundEffectState = false
//            GameState.sharedInstance.saveState()
//            
//            
//            
//        } else {
//            // 恢复音乐播放
//            GameState.sharedInstance.soundEffectState = true
//            GameState.sharedInstance.saveState()
//        }
//    }
    
    // 暂停游戏 ->回主页
    func pauseGoHome() {
        // 退出游戏 回到主场景
        print("暂停游戏 ->回主页", appendNewline: true)
        closePauseUI()
        
        self.paused = false
        isTryAgainGame = false
        
        self.gamePlaydelegate.gameGoHome()
    }
    
    // 暂停游戏 ->重玩
//    func pauseTryAgain() {
//        print("暂停游戏 ->重玩", appendNewline: true)
//        closePauseUI()
//        closeHomePageUI()
//        
//        self.paused = false
//        
//        self.gamePlaydelegate.gameTryAgain()
//    }
    
    // 暂停游戏 ->继续
    func pauseContinue() {
        print("暂停游戏 ->继续", appendNewline: true)
        
        self.paused = false
        closePauseUI()
        pauseButton.hidden = false
        
    }
    
    // 游戏结束 -> 回主页 gameOverGoHome
    func gameOverGoHome() {
        
        closeGameOverUI()
        
        isTryAgainGame = false
        
        print("GameScene ->>> goHome", appendNewline: true)
        self.gamePlaydelegate.gameGoHome()
        
    }
    
    // 游戏结束 －> 重玩
    func gameOverTryAgain() {
        print("GameScene ->>> tryAgainGame:", appendNewline: true)
        
        self.paused = false
        closeGameOverUI()
        closeHomePageUI()
        
        isTryAgainGame = true
        
        self.gamePlaydelegate.gameGoHome()
        
    }
    
    
    //MARK: EnemyCollisionWithPlayerDelegate Method
    //  碰撞检查的委托方法 检测到碰撞敌人， 结束游戏
    func gameSateControll() {
        
        print("gameSateControll >>>>>", appendNewline: true)

        gameOver()

    }
    
    //MARK: 点击事件
    private var state = 0
    
    private var Player_Move_Speed = 0.5
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        // tapToStartNode.removeFromParent()
        // 游戏开始前的设置
        // && isNoOpenUI
        
        if !isGameOver && isPlayerMoveDone && !isOpenUI {
            
            // 开始计算飞行距离
            let touch: AnyObject? = (touches as NSSet).anyObject()
            let locationInNode = touch?.locationInNode(self)
            
            if let location = locationInNode {
                // 
                if isFristRuning {
                    print("首次点击", appendNewline: false)
                    starGame()
                    
                    // 平移
                    // 首次点击 根据左右位置进行判断 移动的方向
                    
                    if (location.x <= self.size.width / 2 && state != -1){
                        playerNode.runAction(SKAction.moveToX(CGRectGetMinX(playableRect) + 30 , duration: Player_Move_Speed))
                        state = -1
                    }
                    else if (location.x >= self.size.width / 2 && state != 1) {
                        playerNode.runAction(SKAction.moveToX(CGRectGetMaxX(playableRect) - 30, duration: Player_Move_Speed))
                        state = 1
                    }
                    
                    isFristRuning = false
                } else {
                    
                    // 不是第一次点击 无需根据点击位置判断 移动的方向
                    if (playerNode.position.x >= self.size.width / 2  && state != -1){
                        playerNode.runAction(SKAction.moveToX(CGRectGetMinX(playableRect) + 30 , duration: Player_Move_Speed))
                        state = -1
                    }
                    else if (playerNode.position.x <= self.size.width / 2 && state != 1) {
                        playerNode.runAction(SKAction.moveToX(CGRectGetMaxX(playableRect) - 30 , duration: Player_Move_Speed))
                        state = 1
                    }
                }
                
            }
        }

    }
    
    var lastSpawnTimeInterval:NSTimeInterval  = 0// 上次更新时间
    var lastUpdateTimeInterval: NSTimeInterval = 0
    
    override func update(currentTime: CFTimeInterval) {
        //print("当前时间:\(currentTime)")
        //scrollBackground()
        
        if isGameBegin {
            playTime++
            movingExtent = Int(self.playTime * playerMoveSpeed)
            scoreLabel.text = "\(Int(movingExtent))"
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




