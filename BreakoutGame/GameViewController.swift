//
//  GameViewController.swift
//  BreakoutGame
//
//  Created by Linsw on 16/3/22.
//  Copyright (c) 2016年 Linsw. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var currentGame: GameScene!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBAction func refreshButtonTap(_ sender: UIButton) {
        currentGame.refreshLevel()
    }
    @IBAction func pauseButtonTap(_ sender: UIButton) {
        if currentGame.isPaused {
            pauseButton.setImage(UIImage(named: "Pause"), for: UIControlState())
        }else{
            pauseButton.setImage(UIImage(named: "Play"), for: UIControlState())
        }
        currentGame.isPaused = !currentGame.isPaused
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            //            scene.scaleMode = .AspectFill
            scene.scaleMode = .resizeFill
            
            skView.presentScene(scene)
            
            currentGame = scene
            scene.viewController = self
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
