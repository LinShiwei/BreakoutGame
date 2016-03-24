//
//  BallNode.swift
//  BreakoutGame
//
//  Created by Linsw on 16/3/23.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import SpriteKit
class BallNode: SKSpriteNode {
    var hasShoot = false
    func setupAtPosition(pos:CGPoint,inNode node:SKNode){
        name = "ball"
        position = CGPoint(x: pos.x + node.position.x, y: pos.y + node.position.y)
        zPosition = NodeZPosition.Ball.rawValue

        configurePhysics()
    }
    func configurePhysics(){
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.0)
        physicsBody!.categoryBitMask = PhysicsCategory.Ball
        physicsBody!.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Spaceship | PhysicsCategory.Ball | PhysicsCategory.Brick | PhysicsCategory.Stone
        physicsBody!.contactTestBitMask = PhysicsCategory.Brick | PhysicsCategory.DeadLine | PhysicsCategory.Spaceship
        physicsBody!.mass = 0.1
        physicsBody!.friction = 0
        physicsBody!.restitution = 1
        physicsBody!.linearDamping = 0
        //        physicsBody!.dynamic = false
    }
    func shootAfterDuration(duration:NSTimeInterval,atAngel angle:CGFloat=CGFloat(M_PI_4)){
        let impulse = CGVector(dx: 75*cos(angle), dy: 75*sin(angle))
        let shootAction = SKAction.sequence([SKAction.waitForDuration(duration),SKAction.runBlock{
            self.hasShoot = true
            self.constraints?.first?.enabled = false
            self.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            self.physicsBody!.applyImpulse(impulse)
            
            }]
        )
        runAction(shootAction)
    }
    func configureDistanceConstraintToPoint(point:CGPoint,inNode node:SKNode){
        let range = SKRange(constantValue: 0)
        let constraint = SKConstraint.distance(range, toPoint: point, inNode: node)
        constraints = [constraint]
    }
}
