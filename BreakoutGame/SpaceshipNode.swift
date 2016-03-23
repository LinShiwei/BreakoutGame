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

    func setupAtPosition(pos:CGPoint){
        name = "spaceship"
        position = pos
        zPosition = NodeZPosition.Spaceship.rawValue

        configurePhysicsWith(size)
        configureConstraints()
    }
    func configurePhysicsWith(bodySize:CGSize){
        physicsBody = SKPhysicsBody(rectangleOfSize: bodySize)
        physicsBody!.categoryBitMask = PhysicsCategory.Spaceship
        physicsBody!.contactTestBitMask = PhysicsCategory.Gift
        physicsBody!.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Wall
        physicsBody!.affectedByGravity = false
        physicsBody!.restitution = 0
        physicsBody!.friction = 1
        physicsBody!.mass = 2
//        physicsBody!.dynamic = false
    }
    func configureConstraints(){
        let rangeY = SKRange(constantValue: position.y)
        let rangeZRotation = SKRange(constantValue: zRotation)
        constraints = [
            SKConstraint.positionY(rangeY),
            SKConstraint.zRotation(rangeZRotation)
        ]
    }
    func strengthenWith(gift:KindOfGift){
        switch gift{
        case .Length:
            self.removeActionForKey("LengthAction")
            let changeLengthAction = SKAction.sequence([
                SKAction.runBlock{
                self.size.width = UIScreen.mainScreen().bounds.width/2
                self.configurePhysicsWith(self.size)
                },
                SKAction.waitForDuration(5),
                SKAction.runBlock{
                
                self.size = shipSize
                self.configurePhysicsWith(self.size)
               
                }]
            )
            runAction(changeLengthAction,withKey: "LengthAction")
        case .Bullet:
            self.removeActionForKey("BulletAction")
            let createBulletAction = SKAction.sequence([
                SKAction.runBlock{
                    self.createBulletAtPosition(CGPoint(x: self.size.width/6, y: 0))
                    self.createBulletAtPosition(CGPoint(x: -self.size.width/6, y: 0))
                },
                SKAction.waitForDuration(0.2)
                ]
            )
            runAction(SKAction.repeatAction(createBulletAction,count: 20),withKey: "BulletAction")
        }
    }
    func createBulletAtPosition(pos:CGPoint){
        let bullet = SKSpriteNode(imageNamed: "Bullet")
        bullet.name = "bullet"
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2.0)
        bullet.physicsBody!.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategory.Brick | PhysicsCategory.Wall | PhysicsCategory.Stone
        bullet.physicsBody!.linearDamping = 0
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.velocity = CGVector(dx: 0, dy: 800)
        bullet.position = pos
        bullet.zPosition = NodeZPosition.Bullet.rawValue
        addChild(bullet)
    }
    
}
