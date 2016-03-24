//
//  Define.swift
//  PinballGame
//
//  Created by Linsw on 16/3/20.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
enum NodeZPosition : CGFloat{
    case Background = 0
    case Bullet
    case Wall,Brick,Spaceship,Label,Stone
    case Gift
    case Ball
    case GameOverNode
    case GameOver
}
enum KindOfGift : String{
    case Length = "LengthGift"
    case Bullet = "BulletGift"
    case Triple = "TripleGift"
    case Magnet = "MagnetGift"
}
let maxLife = 100
let startLevel = 1
let endLevel = 6
let levelFileNamePrefix = "BreakOutGameLevel"
let shipSize = CGSize(width: UIScreen.mainScreen().bounds.size.width*3/10, height: UIScreen.mainScreen().bounds.size.height/40)
