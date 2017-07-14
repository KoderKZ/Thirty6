//
//  TitleScene.swift
//  Thirty6
//
//  Created by Kevin Zhou on 3/30/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class TitleScene:SKScene{
    var titleLabel:SKLabelNode!
    var playLabel:SKLabelNode!
    var doneLoading:Bool!
    var movedAmount:CGFloat!
    var transitioning:Bool!
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(size:CGSize){
        doneLoading = false
        super.init(size:size)
        
        backgroundColor = SKColor(red: 21/255, green: 27/255, blue: 31/255, alpha: 1.0)
        titleLabel = SKLabelNode(text: "Thirty6")
        titleLabel.fontName = "TimeBurner"
        titleLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/4*3)
        titleLabel.fontColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        titleLabel.fontSize = 40
        addChild(titleLabel)
        
        playLabel = SKLabelNode(text: "Swipe Right to Play")
        playLabel.fontName = "TimeBurner"
        playLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/4)
        playLabel.fontColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        playLabel.fontSize = 40
        addChild(playLabel)
        
        movedAmount = 0
        
        doneLoading = true
        transitioning = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: self)
        let previousLocation = touch?.previousLocation(in: self)
        
        if ((location?.x)! > (previousLocation?.x)!) && !transitioning{
            transitioning = true
            let transition = SKTransition.flipVertical(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
    
    
}
