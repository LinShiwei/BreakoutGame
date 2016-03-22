//
//  Define.swift
//  PinballGame
//
//  Created by Linsw on 16/3/20.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import Foundation
import CoreGraphics

enum NodeZPosition : CGFloat{
    case Background = 0
    case Wall,Brick,Spaceship,Label,Stone
    case Gift
    case Ball
    case GameOverNode
    case GameOver
}
let maxLife = 100