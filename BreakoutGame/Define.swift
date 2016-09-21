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
    case background = 0
    case bullet
    case wall,brick,spaceship,label,stone
    case gift
    case ball
    case gameOverNode
    case medalPlate
    case gameOver
}
enum KindOfGift : String{
    case Length = "LengthGift"
    case Bullet = "BulletGift"
    case Triple = "TripleGift"
    case Magnet = "MagnetGift"
}
let maxLife = 5
let startLevel = 1
let endLevel = 2
let levelFileNamePrefix = "BreakOutGameLevel"
let shipSize = CGSize(width: UIScreen.main.bounds.size.width*3/10, height: UIScreen.main.bounds.size.height/40)
