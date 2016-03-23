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
        configureGift()
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
    func configureGift(){
        let randomNumber = RandomInt(min: 1, max: 100)
        switch randomNumber{
        case 1...80:
            name = KindOfGift.Length.rawValue
            color = UIColor.yellowColor()
        case 81...100:
            name = KindOfGift.Bullet.rawValue
            color = UIColor.purpleColor()
        default:break
        }
    }
    
}
