//
//  GiftNode.swift
//  BreakoutGame
//
//  Created by Linsw on 16/3/23.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import SpriteKit
class GiftNode: SKSpriteNode {
    func setupAtPosition(pos:CGPoint){
        configureName()
        position = pos
        zPosition = NodeZPosition.Gift.rawValue
        configurePhysics()
    }
    func configurePhysics(){
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody!.categoryBitMask = PhysicsCategory.Gift
        physicsBody!.contactTestBitMask = PhysicsCategory.Spaceship | PhysicsCategory.DeadLine
        physicsBody!.collisionBitMask = PhysicsCategory.None
        physicsBody!.affectedByGravity = false
        physicsBody!.velocity = CGVector(dx: 0, dy: -100)
        physicsBody!.linearDamping = 0

    }
    func configureName(){
        let randomNumber = RandomInt(min: 1, max: 100)
        switch randomNumber{
        case 1...5:
            name = KindOfGift.Length.rawValue
        case 6...100:
            name = KindOfGift.Bullet.rawValue
        default:break
        }
    }
    
}
