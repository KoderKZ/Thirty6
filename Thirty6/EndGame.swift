//
//  EndGame.swift
//  Thirty6
//
//  Created by Kevin Zhou on 6/22/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit
class EndGame: SKScene {
    var endLabel:SKLabelNode!
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
        
        backgroundColor = .init(red: 255/255, green: 255/255, blue: 224/255, alpha: 1)
        endLabel = SKLabelNode(text: "Good Job!")
        endLabel.fontName = "TimeBurner"
        endLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/4*3)
        endLabel.fontColor = .black
        endLabel.fontSize = 40
        addChild(endLabel)
        
        playLabel = SKLabelNode(text: "Swipe Right to Play Again")
        playLabel.fontName = "TimeBurner"
        playLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/4)
        playLabel.fontColor = .black
        playLabel.fontSize = 30
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
