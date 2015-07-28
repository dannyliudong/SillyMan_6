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
    static let SeaBottom: UInt32 = 0x04 // 碰撞海底
}

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

}


class PlayerNode: GameObjectNode {
    
}

// 敌人
class EnemyNode: GameObjectNode {
    
    var enemyType: EnemyType!
    
    let micON = GameState.sharedInstance.musicState

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

}

// 金币
class StarNode: GameObjectNode {

}

