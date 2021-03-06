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
    static let Bullet    : UInt32 = 0b10
    static let Wall      : UInt32 = 0b100
    static let Brick     : UInt32 = 0b1000
    static let Stone     : UInt32 = 0b10000
    static let Spaceship : UInt32 = 0b100000
    static let Gift      : UInt32 = 0b1000000
    static let DeadLine  : UInt32 = 0b10000000
    static let All       : UInt32 = UInt32.max
    
}
class GameScene: SKScene,SKPhysicsContactDelegate {
    //MARK: Property
    let wallColor = UIColor.black
    let shipColor = UIColor.white
    let giftColor = UIColor.yellow
    let bricksColumn = CGFloat(10)
    let bricksColumnInt = 10
    let brickColors = [UIColor.green,UIColor.red,UIColor.blue]
    var brickSize:CGSize!
    
    weak var viewController: GameViewController!
    
    var motionManager: CMMotionManager!
    
    var levelLabel: SKLabelNode!
    var level: Int = startLevel {
        didSet {
            if let label = levelLabel {
                label.text = "Level: \(level)"
            }
        }
    }
    
    var gobalBestLevel : Int {
        get{
            return fetchGobalBestLevel()
        }
        set{
            
        }
    }
    var bestLevel : Int{
        get{
            return UserDefaults.standard.integer(forKey: "BestLevel")
        }
        set{
            
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
    override func didMove(to view: SKView) {
        brickSize = CGSize(width:size.width/(bricksColumn+1), height: 30)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        start()
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    func start(){
        createBackground()
        createLevelLabel()
        createLifeLabel()
        createSpaceship()
        createWall()
        createDeadLine()
        createBricksAndStonesOfLevel(level)
        createBall()
        
    }
    //MARK: Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameIsOver {
            enterLevelAt()
        }else{
            #if (arch(i386) || arch(x86_64))
                if let touch = touches.first,let spaceshipNode = childNode(withName: "spaceship") {
                    
                    let location = touch.location(in: self)
                    if location.x > spaceshipNode.position.x{
                        spaceshipNode.physicsBody!.velocity = CGVector(dx: 500, dy: 0)
                    }else{
                        spaceshipNode.physicsBody!.velocity = CGVector(dx: -500, dy: 0)
                    }
                }
            #endif
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        #if !(arch(i386) || arch(x86_64))
            if let accelerometerData = motionManager.accelerometerData,let spaceshipNode = childNodeWithName("spaceship") as? SpaceshipNode{
                spaceshipNode.physicsBody!.velocity = CGVector(dx: accelerometerData.acceleration.x * 1200, dy: 0)
            }
        #endif
    }
    //MARK: Create Nodes
    func createBackground(){
        let texture = SKTexture(imageNamed: "Background2")
        let background = SKSpriteNode(texture: texture, size: size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.blendMode = .replace
        background.zPosition = NodeZPosition.background.rawValue
        addChild(background)
    }
    func createLevelLabel(){
        levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelLabel.text = "Level: \(level)"
        levelLabel.position = CGPoint(x: size.width/(bricksColumn+1), y: size.width/(bricksColumn+1)/2)
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.zPosition = NodeZPosition.label.rawValue
        addChild(levelLabel)
    }
    func createLifeLabel(){
        lifeLabel = SKLabelNode(fontNamed: "Chalkduster")
        lifeLabel.text = "Life: \(life)"
        lifeLabel.position = CGPoint(x: size.width/(bricksColumn+1), y: size.width/(bricksColumn+1)/2+50)
        lifeLabel.horizontalAlignmentMode = .left
        lifeLabel.zPosition = NodeZPosition.label.rawValue
        addChild(lifeLabel)
    }
    func createSpaceship(){
        let texture = SKTexture(imageNamed: "Spaceship")
        let spaceship = SpaceshipNode(texture: texture, size: shipSize)
        spaceship.setupAtPosition(CGPoint(x: size.width/2, y: size.height/7 + shipSize.height/2))
        addChild(spaceship)
    }
    func createWall(){
        initWallAtOrientation("Left")
        initWallAtOrientation("Right")
        initWallAtOrientation("Top")
        
    }
    func initWallAtOrientation(_ orientation:String){
        let thickness = self.size.width / (bricksColumn+1)
        let size : CGSize
        let position : CGPoint
        let texture : SKTexture
        switch orientation{
        case "Left":
            texture = SKTexture(imageNamed: "Wall")
            size = CGSize(width: thickness, height: self.size.height)
            position = CGPoint(x: 0, y: self.size.height/2)
        case "Right":
            texture = SKTexture(imageNamed: "Wall")
            size = CGSize(width: thickness, height: self.size.height)
            position = CGPoint(x: self.size.width, y: self.size.height/2)
            
        case "Top":
            texture = SKTexture(imageNamed: "TopWall")
            size = CGSize(width: self.size.width - thickness, height: thickness)
            position = CGPoint(x: self.size.width/2, y: self.size.height)
        default:
            texture = SKTexture(imageNamed: "TopWall")
            size = CGSize(width: self.size.width - thickness, height: thickness)
            position = CGPoint(x: self.size.width/2, y: 0)
        }
        let wall = SKSpriteNode(texture: texture, color: UIColor.blue, size: size)
        wall.name = "wall"
        wall.zPosition = NodeZPosition.wall.rawValue
        wall.position = position
        wall.physicsBody = SKPhysicsBody(texture: texture, size: wall.size)
        wall.physicsBody!.categoryBitMask = PhysicsCategory.Wall
        wall.physicsBody!.collisionBitMask = PhysicsCategory.Ball
        wall.physicsBody!.contactTestBitMask = PhysicsCategory.Bullet
        wall.physicsBody!.affectedByGravity = false
        wall.physicsBody!.restitution = 0
        wall.physicsBody!.isDynamic = false
        addChild(wall)
    }
    func createDeadLine(){
        let deadLine = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width, height: 1))
        deadLine.name = "deadLine"
        deadLine.position = CGPoint(x: size.width/2, y: -brickSize.height)
        deadLine.zPosition = NodeZPosition.wall.rawValue
        deadLine.physicsBody = SKPhysicsBody(rectangleOf: deadLine.size)
        deadLine.physicsBody!.categoryBitMask = PhysicsCategory.DeadLine
        deadLine.physicsBody!.contactTestBitMask = PhysicsCategory.Ball | PhysicsCategory.Gift
        deadLine.physicsBody!.collisionBitMask = PhysicsCategory.None
        deadLine.physicsBody!.affectedByGravity = false
        deadLine.physicsBody!.isDynamic = false
        addChild(deadLine)
    }
    func createBrickAt(row:Int,column:Int){
        let imageName = "Brick" + String(RandomInt(min: 1, max: 4))
        let texture = SKTexture(imageNamed: imageName)
        let brick = SKSpriteNode(texture: texture, size: brickSize)
        brick.position = CGPoint(x: CGFloat(column+1) * brickSize.width, y: size.height-brickSize.width/2+brickSize.height/2-CGFloat(row+1)*brickSize.height)
        brick.zPosition = NodeZPosition.brick.rawValue
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody!.categoryBitMask = PhysicsCategory.Brick
        brick.physicsBody!.collisionBitMask = PhysicsCategory.Ball
        brick.physicsBody!.contactTestBitMask = PhysicsCategory.Ball
        brick.physicsBody!.affectedByGravity = false
        brick.physicsBody!.restitution = 0
        brick.physicsBody!.isDynamic = false
        brick.name = "brick"
        addChild(brick)
    }
    func createStoneAt(row:Int,column:Int){
        let texture = SKTexture(imageNamed: "Stone")
        let stone = SKSpriteNode(texture: texture, size: brickSize)
        stone.position = CGPoint(x: CGFloat(column+1) * brickSize.width, y: size.height-brickSize.width/2+brickSize.height/2-CGFloat(row+1)*brickSize.height)
        stone.zPosition = NodeZPosition.stone.rawValue
        stone.physicsBody = SKPhysicsBody(rectangleOf: stone.size)
        stone.physicsBody!.categoryBitMask = PhysicsCategory.Stone
        stone.physicsBody!.collisionBitMask = PhysicsCategory.Ball
        stone.physicsBody!.contactTestBitMask = PhysicsCategory.Bullet
        stone.physicsBody!.affectedByGravity = false
        stone.physicsBody!.restitution = 0
        stone.physicsBody!.isDynamic = false
        stone.name = "stone"
        addChild(stone)
    }
    func createBricksAndStonesOfLevel(_ level:Int = startLevel) {
        let fileName = levelFileNamePrefix + String(level)
        if let levelPath = Bundle.main.path(forResource: fileName, ofType: "txt"),
            let levelString = try? String(contentsOfFile: levelPath) {
//                let manager = NSFileManager.defaultManager()
//                do{
//                    let string = try manager.contentsOfDirectoryAtPath(NSBundle.mainBundle().resourcePath!)
//                    print(string)
//                }catch{
//                    
//                }
//                print(NSBundle.mainBundle().resourcePath)
//                let appFilePath = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]) + "/"
//                print(appFilePath)
//                print(levelPath)
                let lines = levelString.components(separatedBy: "\n")
                for (row, line) in lines.enumerated() {
                    for (column, letter) in line.characters.enumerated() where line.characters.count<=bricksColumnInt{
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
        guard let spaceshipNode = childNode(withName: "spaceship") as? SpaceshipNode else{return}
        let ball = BallNode(imageNamed: "BallBlue")
        let point = CGPoint(x: spaceshipNode.size.width/6, y: spaceshipNode.size.height/2+ball.size.height/2)
        ball.setupAtPosition(point,inNode:spaceshipNode)
        ball.configureDistanceConstraintToPoint(point, inNode: spaceshipNode)
        addChild(ball)
        ball.shootAfterDuration(2)
    }
    func createGiftAtPosition(_ pos:CGPoint){
        let gift = GiftNode(color: giftColor, size: brickSize)
        gift.setupAtPosition(pos)
        addChild(gift)
    }
    func createGameOverNode(){
        let medalPlate = createMedalPlate()
        
        let gameOverLabel = SKSpriteNode(texture: SKTexture(imageNamed: "GameOver"))
        gameOverLabel.position = CGPoint(x: size.width/2,y: size.height/2 + medalPlate.size.height*2/3)
        gameOverLabel.zPosition = NodeZPosition.gameOver.rawValue
        
        let gameOverNode = SKSpriteNode(color: UIColor(white: 0.2, alpha: 0.3), size: size)
        gameOverNode.anchorPoint = CGPoint(x: 0, y: 0)
        gameOverNode.zPosition = NodeZPosition.gameOverNode.rawValue
        gameOverNode.addChild(medalPlate)
        gameOverNode.addChild(gameOverLabel)
        gameOverNode.name = "gameOverNode"
        addChild(gameOverNode)
    }
    func createMedalPlate()->SKSpriteNode{
        let medalPlate = SKSpriteNode(texture: SKTexture(imageNamed: "MedalPlate"))
        medalPlate.position = CGPoint(x: size.width/2,y: size.height/2)
        medalPlate.zPosition = NodeZPosition.medalPlate.rawValue
        
        
        let currentLevelLabel = SKLabelNode(text:"Level " + String(level))
        currentLevelLabel.fontName = "Helvetica-Bold"
        currentLevelLabel.zPosition = medalPlate.zPosition
        currentLevelLabel.fontSize = 36/232 * medalPlate.size.height
        currentLevelLabel.fontColor = UIColor(white: 0.3, alpha: 1)
        currentLevelLabel.horizontalAlignmentMode = .right
        currentLevelLabel.position = CGPoint(x: medalPlate.size.width*180/452, y: medalPlate.size.height*16/232)
        medalPlate.addChild(currentLevelLabel)
        
        let bestLevelLabel = SKLabelNode(text:"Level " + String(bestLevel))
        bestLevelLabel.fontName = "Helvetica-Bold"
        bestLevelLabel.zPosition = medalPlate.zPosition
        bestLevelLabel.fontSize = 36/232 * medalPlate.size.height
        bestLevelLabel.fontColor = UIColor(white: 0.3, alpha: 1)
        bestLevelLabel.horizontalAlignmentMode = .right
        bestLevelLabel.position = CGPoint(x: medalPlate.size.width*180/452, y: -medalPlate.size.height*70/232)
        medalPlate.addChild(bestLevelLabel)
        
        let gobalBestLevelLabel = SKLabelNode(text:"Level " + String(gobalBestLevel))
        gobalBestLevelLabel.fontName = "Helvetica-Bold"
        gobalBestLevelLabel.zPosition = medalPlate.zPosition
        gobalBestLevelLabel.fontSize = 36/232 * medalPlate.size.height
        gobalBestLevelLabel.fontColor = UIColor(white: 0.3, alpha: 1)
        gobalBestLevelLabel.horizontalAlignmentMode = .right
        gobalBestLevelLabel.position = CGPoint(x: -medalPlate.size.width*180/452, y: -medalPlate.size.height*70/232)
//        medalPlate.addChild(gobalBestLevelLabel)
        
        return medalPlate
    }
    //MARK: Contact
    func didBegin(_ contact: SKPhysicsContact) {
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
            switch (firstNode.name , secondNode.name){
            case ("ball"?,"brick"?):
                ballHitBrick(ball:firstNode as! BallNode, brick: secondNode as! SKSpriteNode)
            case ("ball"?,"spaceship"?):
                ballHitSpaceship(firstNode as! BallNode)
            case ("spaceship"?,_):
                if secondNode is GiftNode {
                    spaceshipEatGift(spaceship: firstNode as! SpaceshipNode, gift: secondNode as! GiftNode)
                }
            case (_,"deadLine"?):
                nodeHitDeadLine(firstNode as! SKSpriteNode)
            case ("bullet"?,"wall"?),("bullet"?,"stone"?):
                bulletHitWall(firstNode as! SKSpriteNode)
            case ("bullet"?,"brick"?):
                bulletHitBrick(secondNode as! SKSpriteNode, bullet: firstNode as! SKSpriteNode)
            default:
                break

            }
        }
    }
    func ballHitBrick(ball:BallNode,brick:SKSpriteNode){
        destoryBrick(brick)
    }
    func ballHitSpaceship(_ ball:BallNode){
        guard ball.hasShoot else{return}
        run(SKAction.playSoundFileNamed("Ping.caf", waitForCompletion: false))
    }
    func spaceshipEatGift(spaceship:SpaceshipNode,gift:GiftNode){
        spaceship.strengthenWith(KindOfGift(rawValue: gift.name!)!)
        gift.name = ""
        gift.removeFromParent()
    }
    func nodeHitDeadLine(_ node:SKSpriteNode){
        if node.name == "ball"{
            node.name = ""
            node.removeFromParent()
            guard let _ = childNode(withName: "ball") else{
                run(SKAction.playSoundFileNamed("Basso.caf", waitForCompletion: false))
                life -= 1
                if life == 0 {
                    gameOver()
                }else{
                    createBall()
                }
                return
            }
            
        }else{
            node.name = ""
            node.removeFromParent()
        }
    }
    func bulletHitWall(_ bullet:SKSpriteNode){
        consumeBullet(bullet)
    }
    func bulletHitBrick(_ brick:SKSpriteNode,bullet:SKSpriteNode){
        destoryBrick(brick)
        consumeBullet(bullet)
    }
    func destoryBrick(_ brick:SKSpriteNode){
        if RandomInt(min: 1, max: 100) < 50 {
            createGiftAtPosition(brick.position)
        }
        run(SKAction.playSoundFileNamed("Pop.caf", waitForCompletion: false))
        brick.name = ""
        brick.removeFromParent()
        if let _ = childNode(withName: "brick"){
        }else{
            if level+1 > endLevel {
                enterLevelAt(level: endLevel)
            }else{
                enterLevelAt(level:level+1)
            }
        }
    }
    func consumeBullet(_ bullet:SKSpriteNode){
        bullet.name = ""
        bullet.removeFromParent()
    }
    //MARK: Game Cycle
    func gameOver(){
        if let spaceship = childNode(withName: "spaceship"){
            spaceship.removeAllActions()
        }
        gameIsOver = true
        physicsWorld.speed = 0
        recordLevel()
        createGameOverNode()
        
    }
    func refreshLevel(){
        enumerateChildNodes(withName: "ball"){ ball,_ in
            ball.name = ""
            ball.removeFromParent()
        }
        life -= 1
        if life == 0 {
            gameOver()
        }else{
            createBall()
        }
    
    }
    func enterLevelAt(level:Int=startLevel){
        let currentLife = life
        let newGame = GameScene(size: self.size)
        newGame.level = level
        newGame.viewController = self.viewController
        physicsWorld.speed = 0
        self.viewController.currentGame = newGame
        
        let transition = SKTransition.crossFade(withDuration: 1)
        self.view?.presentScene(newGame, transition: transition)
        if level == startLevel {
            newGame.life = maxLife
        }else{
            newGame.life = currentLife
        }
    }
    //MARK:
    func fetchGobalBestLevel()->Int{
        return 10
    }
    func updateGobalBestLevelWith(_ level:Int) {
        
    }
    func recordLevel(){
        if level > bestLevel {
            UserDefaults.standard.setValue(level, forKey: "BestLevel")
            bestLevel = level
        }
        if level > gobalBestLevel {
            updateGobalBestLevelWith(level)
        }
    }
}
