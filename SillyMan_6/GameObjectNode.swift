//
//  GameObjectNode.swift
//  TinyWings
//
//  Created by liudong on 15/6/3.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import UIKit
import SpriteKit

struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01 // 1 吃到加成
    static let Enemy: UInt32 = 0x02 // 2 吃到敌人 game over
    //static let Edge:  UInt32 = 0b100 // 4 游戏区域边缘
    //static let Edge1:  UInt32 = 0b1000 // 8 游戏区域边缘
    
}

//struct PhysicsCategory {
//    static let None:  UInt32 = 0
//    static let Player:UInt32 = 0b1   // 1
//    static let Block: UInt32 = 0b10  // 2
//    static let enemy: UInt32 = 0b100 // 4
//    static let Edge:  UInt32 = 0b1000 // 8
//    static let Star: UInt32 = 0b10000 // 16
//    static let Spring:UInt32 = 0b100000 // 32
//    static let Hook:  UInt32 = 0b1000000 // 64
//}


enum EnemyType: Int {
    case Normal = 0
    case SpecialRotate // 旋转的
    case SpecialActive // 会移动的
    case SpecialHidden // 会隐身的
    
   static func randomEnemyType() ->EnemyType {
        switch arc4random()%5 {
        case 0: return EnemyType.Normal
        case 1: return EnemyType.SpecialRotate
        case 2: return EnemyType.SpecialActive
        case 3: return EnemyType.SpecialHidden
        default: return EnemyType.Normal
        }
    }
}

enum StarType: Int {
    case Normal = 0
    case Special
}

class GameObjectNode: SKNode {
    
    func collisionWithPlayer(player: SKNode) -> Bool {
        return false
    }

}

protocol EnemyCollisionWithPlayerDelegate {
    func gameSateControll()
}


class EnemyNode: GameObjectNode {
    
    var enemyType: EnemyType!
    var delegate:EnemyCollisionWithPlayerDelegate?
    
    let micON = GameState.sharedInstance.soundEffectState

    
    var isGetOne: Bool = false
    
    func createEnemyNode(sprite:SKSpriteNode, ofPosition position:CGPoint, ofType type:EnemyType) ->EnemyNode {
        let _node = EnemyNode()
        
        _node.position = position
        _node.enemyType = type
    
        let sp = sprite
        _node.addChild(sp)
        
        _node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        _node.physicsBody?.dynamic = true
        
        _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        _node.physicsBody?.collisionBitMask = 0
        _node.physicsBody?.contactTestBitMask = 0
        
        return _node
    }
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        // 如果关闭了音乐控制按钮 不播放音乐
        
        let enemySound = SKAction.playSoundFileNamed("collisionSound.wav", waitForCompletion: false)
        
        if micON {
            runAction(enemySound)
        }
        
        self.delegate?.gameSateControll()

        return true
    }
}

class PlayerNode: GameObjectNode {
    var playerSpeed = 0.0
    
}

//  加星
class StarNode: GameObjectNode {
    
    var starType: StarType!
    let micON = GameState.sharedInstance.soundEffectState
    
    let starSound = SKAction.playSoundFileNamed("Get.wav", waitForCompletion: false)
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        
        if micON {
            runAction(starSound, completion: { () -> Void in
                self.removeFromParent()
            })
        }
        
        // 星数
        GameState.sharedInstance.stars += 1
        
        return true
    }
    
}

