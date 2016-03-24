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
        physicsBody!.contactTestBitMask = PhysicsCategory.Gift | PhysicsCategory.Ball
        physicsBody!.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Wall
        physicsBody!.mass = 10
        physicsBody!.affectedByGravity = false
        physicsBody!.restitution = 0
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
                if let scene = self.parent as? SKScene {
                    scene.enumerateChildNodesWithName("ball"){ [weak self] ball,_ in
                        if let ballNode = ball as? BallNode where !ballNode.hasShoot{
                            let point = CGPoint(x: self!.size.width/6, y: self!.size.height/2+ballNode.size.height/2)
                            ballNode.configureDistanceConstraintToPoint(point,inNode:self!)
                        }
                    }
                }
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
        case .Triple:
            if let gameScene = self.parent,let ball = gameScene.childNodeWithName("ball") as? BallNode,let velocity = ball.physicsBody?.velocity{

                var angle :CGFloat
                if velocity == CGVector(dx: 0, dy: 0) {
                    angle = 3.14/4.0
                }else{
                    angle = atan(velocity.dy/velocity.dx)
                    if velocity.dy < 0 && velocity.dx < 0{
                        angle += 3.14
                    }
                }
                let texture = SKTexture(imageNamed: "BallBlue")
                let newBall1 = BallNode(texture: texture)
                newBall1.setupAtPosition(ball.position, inNode: gameScene)
                gameScene.addChild(newBall1)
                newBall1.shootAfterDuration(0,atAngel: angle + 0.26)
                let newBall2 = BallNode(texture: texture)
                newBall2.setupAtPosition(ball.position, inNode: gameScene)
                gameScene.addChild(newBall2)
                newBall2.shootAfterDuration(0,atAngel: angle - 0.26)
            }
        default:
            break
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
