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
        case 1...32:
            name = KindOfGift.Length.rawValue
            color = UIColor.blueColor()
        case 33...65:
            name = KindOfGift.Bullet.rawValue
            color = UIColor.redColor()
        case 66...99:
            name = KindOfGift.Triple.rawValue
            color = UIColor.greenColor()
        case 100:
            name = KindOfGift.Magnet.rawValue
            color = UIColor.purpleColor()
        default:break
        }
    }
    
}
