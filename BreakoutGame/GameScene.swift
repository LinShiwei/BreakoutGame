//
//  GameScene.swift
//  BreakoutGame
//
//  Created by Linsw on 16/3/22.
//  Copyright (c) 2016年 Linsw. All rights reserved.
//
import CoreMotion
import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let Ball      : UInt32 = 0b1
    static let Wall      : UInt32 = 0b10
    static let Brick     : UInt32 = 0b100
    static let Stone     : UInt32 = 0b1000
    static let Spaceship : UInt32 = 0b10000
    static let Track     : UInt32 = 0b100000
    static let Gift      : UInt32 = 0b1000000
    static let All       : UInt32 = UInt32.max
    
}
class GameScene: SKScene,SKPhysicsContactDelegate {
    //MARK: Property
    let wallColor = UIColor.blackColor()
    let shipColor = UIColor.whiteColor()
    let spaceshipSpeed = CGFloat(90)
    let ballSpeed = CGFloat(300)
    let bricksRow = CGFloat(1)
    let bricksColumn = CGFloat(10)
    let bricksColumnInt = 10
    let brickColors = [UIColor.greenColor(),UIColor.redColor(),UIColor.blueColor()]
    var brickSize:CGSize!
    
    weak var viewController: GameViewController!
    
    var motionManager: CMMotionManager!
    
    var LevelLabel: SKLabelNode!
    var level: Int = 0 {
        didSet {
            LevelLabel.text = "Level: \(level)"
        }
    }
    var lifeLabel: SKLabelNode!
    var life: Int = maxLife {
        didSet {
            lifeLabel.text = "Life: \(life)"
        }
    }
    var gameIsOver = false
    
    //MARK: View
    override func didMoveToView(view: SKView) {
        brickSize = CGSize(width:size.width/(bricksColumn+1), height: 30)
        start()
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    func start(){
        createBackground()
        createLevelLabel()
        createLifeLabel()
        createSpaceship()
        createTracks()
        createWall()
        createBricks()
        createBall()
        
    }
    //MARK: Touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameIsOver {
            enterLevelAt(level:0)
        }else{
            #if (arch(i386) || arch(x86_64))
                if let touch = touches.first,let spaceshipNode = childNodeWithName("spaceship") {
                    
                    let location = touch.locationInNode(self)
                    if location.x > spaceshipNode.position.x{
                        spaceshipNode.physicsBody!.velocity = CGVector(dx: 500, dy: 0)
                    }else{
                        spaceshipNode.physicsBody!.velocity = CGVector(dx: -500, dy: 0)
                    }
                }
            #endif
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        #if !(arch(i386) || arch(x86_64))
            if let accelerometerData = motionManager.accelerometerData,let spaceshipNode = childNodeWithName("spaceship") as? SpaceshipNode{
                spaceshipNode.physicsBody!.velocity = CGVector(dx: accelerometerData.acceleration.x * 1000, dy: 0)
            }
        #endif
        if let ball = childNodeWithName("ball") where ball.position.y < 0 {
            ball.name = ""
            ball.removeFromParent()
            life -= 1
            if life == 0 {
                gameOver()
            }else{
                createBall()
            }
        }
    }
    
    func createBackground(){
        let texture = SKTexture(imageNamed: "Background")
        let background = SKSpriteNode(texture: texture, color: UIColor.clearColor(), size: size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.blendMode = .Replace
        background.zPosition = NodeZPosition.Background.rawValue
        addChild(background)
    }
    func createLevelLabel(){
        LevelLabel = SKLabelNode(fontNamed: "Chalkduster")
        LevelLabel.text = "Level: \(level)"
        LevelLabel.position = CGPoint(x: size.width/(bricksColumn+1), y: size.width/(bricksColumn+1)/2)
        LevelLabel.horizontalAlignmentMode = .Left
        LevelLabel.zPosition = NodeZPosition.Label.rawValue
        addChild(LevelLabel)
    }
    func createLifeLabel(){
        lifeLabel = SKLabelNode(fontNamed: "Chalkduster")
        lifeLabel.text = "Life: \(life)"
        lifeLabel.position = CGPoint(x: size.width/(bricksColumn+1), y: size.width/(bricksColumn+1)/2+50)
        lifeLabel.horizontalAlignmentMode = .Left
        lifeLabel.zPosition = NodeZPosition.Label.rawValue
        addChild(lifeLabel)
    }
    
    func createTracks(){
        let topTrack = createTrackAt(CGPoint(x: size.width/2, y: size.height/7 + size.height/40))
        addChild(topTrack)
        let bottomTrack = createTrackAt(CGPoint(x: size.width/2, y: size.height/7))
        addChild(bottomTrack)
        
    }
    func createTrackAt(position:CGPoint)->SKSpriteNode{
        let track = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width:size.width,height:1))
        track.zPosition = NodeZPosition.Spaceship.rawValue
        //        track.position = CGPoint(x: size.width/2, y: size.height/7)
        track.position = position
        track.physicsBody = SKPhysicsBody(rectangleOfSize: track.size)
        track.physicsBody!.categoryBitMask = PhysicsCategory.Track
        track.physicsBody!.collisionBitMask = PhysicsCategory.Spaceship
        track.physicsBody!.friction = 0
        track.physicsBody!.affectedByGravity = false
        track.physicsBody!.dynamic = false
        return track
    }
    func createSpaceship(){
        let shipSize = CGSize(width: size.width*5/10, height: size.height/40)
        let spaceship = SpaceshipNode(color: shipColor, size: shipSize)
        spaceship.setup()
        spaceship.position = CGPoint(x: size.width/2, y: size.height/7 + shipSize.height/2)
        spaceship.zPosition = NodeZPosition.Spaceship.rawValue
        addChild(spaceship)
    }
    func createWall(){
        initWallAtOrientation("Left")
        initWallAtOrientation("Right")
        //        initWallAtOrientation("Bottom")
        initWallAtOrientation("Top")
        
    }
    func initWallAtOrientation(orientation:String){
        let thickness = self.size.width / (bricksColumn+1)
        let size : CGSize
        let position : CGPoint
        switch orientation{
        case "Left":
            size = CGSize(width: thickness, height: self.size.height)
            position = CGPoint(x: 0, y: self.size.height/2)
        case "Right":
            size = CGSize(width: thickness, height: self.size.height)
            position = CGPoint(x: self.size.width, y: self.size.height/2)
            
        case "Top":
            size = CGSize(width: self.size.width - thickness, height: thickness)
            position = CGPoint(x: self.size.width/2, y: self.size.height)
        default:
            size = CGSize(width: self.size.width - thickness, height: thickness)
            position = CGPoint(x: self.size.width/2, y: 0)
        }
        let wall = SKSpriteNode(color: wallColor, size: size)
        wall.zPosition = NodeZPosition.Wall.rawValue
        wall.position = position
        wall.physicsBody = SKPhysicsBody(rectangleOfSize: wall.size)
        wall.physicsBody!.categoryBitMask = PhysicsCategory.Wall
        wall.physicsBody!.collisionBitMask = PhysicsCategory.Ball
        wall.physicsBody!.contactTestBitMask = PhysicsCategory.None
        wall.physicsBody!.affectedByGravity = false
        wall.physicsBody!.dynamic = false
        addChild(wall)
    }
    func createBricks(){
        for row in 1...Int(bricksRow){
            for column in 1...Int(bricksColumn)-5{
                createBrickAt(row: row, column: column)
            }
        }
        
    }
    func createBrickAt(row row:Int,column:Int){
        let color = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(brickColors) as! [UIColor]
        let brick = SKSpriteNode(color: color[0], size: brickSize)
        brick.position = CGPoint(x: CGFloat(column) * brickSize.width, y: size.height-brickSize.width/2+brickSize.height/2-CGFloat(row)*brickSize.height - size.height/4)
        
        brick.zPosition = NodeZPosition.Brick.rawValue
        brick.physicsBody = SKPhysicsBody(rectangleOfSize: brick.size)
        brick.physicsBody!.categoryBitMask = PhysicsCategory.Brick
        brick.physicsBody!.collisionBitMask = PhysicsCategory.Ball
        brick.physicsBody!.contactTestBitMask = PhysicsCategory.Ball
        brick.physicsBody!.affectedByGravity = false
        brick.physicsBody!.dynamic = false
        brick.name = "brick"
        addChild(brick)
    }
    func createStoneAt(row row:Int,column:Int){
        let stone = SKSpriteNode(color: UIColor.grayColor(), size: brickSize)
        stone.position = CGPoint(x: CGFloat(column) * brickSize.width, y: size.height-brickSize.width/2+brickSize.height/2-CGFloat(row)*brickSize.height - size.height/4)
        
        stone.zPosition = NodeZPosition.Stone.rawValue
        stone.physicsBody = SKPhysicsBody(rectangleOfSize: stone.size)
        stone.physicsBody!.categoryBitMask = PhysicsCategory.Stone
        stone.physicsBody!.collisionBitMask = PhysicsCategory.Ball
        stone.physicsBody!.contactTestBitMask = PhysicsCategory.None
        stone.physicsBody!.affectedByGravity = false
        stone.physicsBody!.dynamic = false
        stone.name = "stone"
        addChild(stone)
    }
    func createBricksAndStonesOfLevel(level:Int=1) {
        
        if let levelPath = NSBundle.mainBundle().pathForResource("level1", ofType: "txt"),
            let levelString = try? String(contentsOfFile: levelPath, usedEncoding: nil) {
                
                let lines = levelString.componentsSeparatedByString("\n")
                
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() where line.characters.count<=bricksColumnInt{
                        if letter == "s" {
                            createStoneAt(row: row, column: column)
                        } else if letter == "b" {
                            createBrickAt(row: row, column: column)
                        }
                    }
                }
                
        }
    }
    func createBall(){
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody!.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody!.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Spaceship | PhysicsCategory.Ball | PhysicsCategory.Brick
        ball.physicsBody!.contactTestBitMask = PhysicsCategory.Brick
        ball.physicsBody!.mass = 0.1
        ball.physicsBody!.friction = 1
        ball.physicsBody!.restitution = 1
        ball.physicsBody!.linearDamping = 0
        
        //        ball.physicsBody!.dynamic = false
        
        guard let spaceshipNode = childNodeWithName("spaceship") as? SpaceshipNode else{return}
        var pos = spaceshipNode.position
        pos.x += spaceshipNode.size.width/3
        pos.y += spaceshipNode.size.height/2 + ball.size.height/2
        ball.position = pos
        ball.zPosition = NodeZPosition.Ball.rawValue
        ball.name = "ball"
        addChild(ball)
        shootBall()
    }
    func shootBall(){
        guard let ballNode = childNodeWithName("ball") as? SKSpriteNode else{return}
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        let shootAction = SKAction.sequence([SKAction.waitForDuration(2),SKAction.runBlock{
            self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            self.physicsWorld.contactDelegate = self
            ballNode.physicsBody!.friction = 0
            ballNode.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            ballNode.physicsBody!.applyImpulse(CGVector(dx: 40, dy: 40))
            
            }]
        )
        ballNode.runAction(shootAction)
    }
    func createGameOverNode(){
        let gameOverLabel = SKSpriteNode(texture: SKTexture(imageNamed: "GameOver"))
        gameOverLabel.position = CGPointMake(size.width/2, size.height/2)
        gameOverLabel.zPosition = NodeZPosition.GameOver.rawValue
        
        let gameOverNode = SKSpriteNode(color: UIColor(white: 0.2, alpha: 0.3), size: size)
        gameOverNode.anchorPoint = CGPoint(x: 0, y: 0)
        gameOverNode.zPosition = NodeZPosition.GameOverNode.rawValue
        gameOverNode.addChild(gameOverLabel)
        gameOverNode.name = "gameOverNode"
        addChild(gameOverNode)
    }
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if let firstNode = firstBody.node , let secondNode = secondBody.node {
            if firstNode.name == "ball" && secondNode.name == "brick" {
                ballHitBrick(ball:firstNode as! SKSpriteNode, brick: secondNode as! SKSpriteNode)
            }
        }
    }
    func ballHitBrick(ball ball:SKSpriteNode,brick:SKSpriteNode){
        brick.name = ""
        brick.removeFromParent()
        if let _ = childNodeWithName("brick"){
            //            score += 10
        }else{
            enterLevelAt(level:level+1)
        }
    }
    func gameOver(){
        gameIsOver = true
        physicsWorld.speed = 0
        createGameOverNode()
    }
    func enterLevelAt(level level:Int){
        let currentLife = life
        let newGame = GameScene(size: self.size)
        
        newGame.viewController = self.viewController
        physicsWorld.speed = 0
        self.viewController.currentGame = newGame
        
        let transition = SKTransition.crossFadeWithDuration(1)
        self.view?.presentScene(newGame, transition: transition)
        newGame.level = level
        if level == 0 {
            newGame.life = maxLife
        }else{
            newGame.life = currentLife
        }
    }
}
