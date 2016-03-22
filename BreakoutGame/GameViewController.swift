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
    @IBAction func refreshButtonTap(sender: UIButton) {
        currentGame.refreshLevel()
    }
    @IBAction func pauseButtonTap(sender: UIButton) {
        if currentGame.paused {
            pauseButton.setImage(UIImage(named: "Pause"), forState: .Normal)
        }else{
            pauseButton.setImage(UIImage(named: "Play"), forState: .Normal)
        }
        currentGame.paused = !currentGame.paused
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
            scene.scaleMode = .ResizeFill
            
            skView.presentScene(scene)
            
            currentGame = scene
            scene.viewController = self
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
