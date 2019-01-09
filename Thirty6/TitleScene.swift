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
    var helpNode:SKNode!
    var gameLogic:GameLogic!
    var tutorialPage:SKNode!
    var inTutorial:Bool!
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(size:CGSize){
        doneLoading = false
        super.init(size:size)
        
        backgroundColor = SKColor(red: 21/255, green: 27/255, blue: 31/255, alpha: 1.0)
        
        gameLogic = GameLogic()
        
        inTutorial = false
        
        helpNode = SKNode()
        
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
        
        let helpQuestionMark = SKLabelNode(text: "?")
        helpQuestionMark.fontColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        helpQuestionMark.fontSize = 20
        helpQuestionMark.horizontalAlignmentMode = .center
        helpQuestionMark.verticalAlignmentMode = .center
        helpQuestionMark.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        helpQuestionMark.fontName = "TimeBurner"
        
        let helpCircle = SKShapeNode(circleOfRadius: helpQuestionMark.frame.size.height*4/5)
        helpCircle.fillColor = self.backgroundColor
        helpCircle.lineWidth = 2
        helpCircle.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        helpCircle.strokeColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        
        helpNode.addChild(helpCircle)
        helpNode.addChild(helpQuestionMark)
        
        helpNode.position = CGPoint(x: self.frame.size.width/2-helpCircle.frame.size.width, y: self.frame.size.height/2-helpCircle.frame.size.width)
        
        tutorialPage = SKNode()
        
        tutorialPage.position = CGPoint(x: 0, y: -self.frame.size.height-10)
        
        let backgroundLayer = SKShapeNode(rectOf: size)
        backgroundLayer.fillColor = .black
        backgroundLayer.alpha = 0.8
        backgroundLayer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        tutorialPage.addChild(backgroundLayer)
        
        let tutorialText = SKLabelNode(fontNamed: "TimeBurner")
        tutorialText.fontSize = self.frame.size.width/27
        tutorialText.verticalAlignmentMode = .top
        tutorialText.horizontalAlignmentMode = .left
        tutorialText.fontColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        tutorialText.text = "The goal of the game is to use the four basic \n\noperations to get to the final number: 36! \n\n\nTo switch operations, \n\nswipe left or right near the operations.\n\n\nTo operate on the numbers,\n\n select the operation you want. \n\n\nThen, tap the first number you want to select, \n\nthen tap the next number. \n\nOrder does matter, so if you want to subtract 4 from 2, \n\nyou must select 4 first, then tap 2 to get the number 2.\n\nTo undo a mistake, \n\ntap and hold onto a number that has been operated on. \n\nThese numbers are highlighted by a light color. \n\nThat's all! Good luck!"
        let label = tutorialText.multilined()
        label.zPosition = 1001
        label.position = CGPoint(x: self.frame.size.width/20, y: self.frame.size.height*9/14)
        tutorialPage.addChild(label)
        
        addChild(tutorialPage)
        
        movedAmount = 0
        
        doneLoading = true
        transitioning = false
        
        addChild(helpNode)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch = touches.first?.location(in: self)
        let node = self.atPoint(touch!)
        if node == helpNode.children[0] || node == helpNode.children[1] || node == helpNode{
            if tutorialPage.position.y != 0{
                tutorialPage.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.25))
                inTutorial = true
            }else{
                tutorialPage.run(SKAction.move(to: CGPoint(x: 0, y: -self.frame.size.height-10), duration: 0.25))
                inTutorial = false
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: self)
        let previousLocation = touch?.previousLocation(in: self)
        
        if ((location?.x)! > (previousLocation?.x)!) && !transitioning && !inTutorial{
            transitioning = true
            let transition = SKTransition.flipVertical(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
    
    
}
