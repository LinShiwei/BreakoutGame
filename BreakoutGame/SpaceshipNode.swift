//
//  SpaceshipNode.swift
//  PinballGame
//
//  Created by Linsw on 16/3/21.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import SpriteKit
class SpaceshipNode: SKSpriteNode {

    func setup(){
        name = "spaceship"
     
        configurePhysics()
    }
    func configurePhysics(){
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody!.categoryBitMask = PhysicsCategory.Spaceship
        physicsBody!.contactTestBitMask = PhysicsCategory.Gift
        physicsBody!.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Wall | PhysicsCategory.Track
        physicsBody!.affectedByGravity = false
        physicsBody!.mass = 2
//        physicsBody!.dynamic = false
    }
    
}
