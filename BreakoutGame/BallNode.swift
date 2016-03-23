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

    func setupAtPosition(pos:CGPoint,inNode node:SKNode){
        name = "ball"
        position = CGPoint(x: pos.x + node.position.x, y: pos.y + node.position.y)
        zPosition = NodeZPosition.Ball.rawValue

        configurePhysics()
        configureDistanceConstraintToPoint(pos, inNode: node)
    }
    func configurePhysics(){
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.0)
        physicsBody!.categoryBitMask = PhysicsCategory.Ball
        physicsBody!.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Spaceship | PhysicsCategory.Ball | PhysicsCategory.Brick | PhysicsCategory.Stone
        physicsBody!.contactTestBitMask = PhysicsCategory.Brick | PhysicsCategory.DeadLine
        physicsBody!.mass = 0.1
        physicsBody!.friction = 1
        physicsBody!.restitution = 1
        physicsBody!.linearDamping = 0
        //        physicsBody!.dynamic = false
        

    }
    func shootAfterDuration(duration:NSTimeInterval){
        let shootAction = SKAction.sequence([SKAction.waitForDuration(duration),SKAction.runBlock{
            
            self.constraints?.first?.enabled = false
            self.physicsBody!.friction = 0
            self.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            self.physicsBody!.applyImpulse(CGVector(dx: 40, dy: 40))
            
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
