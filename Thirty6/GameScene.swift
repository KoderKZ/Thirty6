//
//  GameScene.swift
//  Thirty6
//
//  Created by Kevin Zhou on 3/30/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import SpriteKit
import GameplayKit



class GameScene: SKScene {
    
    var operation1:Int!
    var operation2:Int!
    var operation3:Int!
    var operation4:Int!
    
    var ThirtysixLabel:SKLabelNode!
    var firstNumberNode:SKNode!
    var secondNumberNode:SKNode!
    var thirdNumberNode:SKNode!
    var fourthNumberNode:SKNode!
    
    var firstNumberLabel:SKLabelNode!
    var secondNumberLabel:SKLabelNode!
    var thirdNumberLabel:SKLabelNode!
    var fourthNumberLabel:SKLabelNode!
    
    var addSprite:SKSpriteNode!
    var subtractSprite:SKSpriteNode!
    var multiplySprite:SKSpriteNode!
    var divideSprite:SKSpriteNode!
    
    var moveNodeIndex:Int!
    var moveOperationIndex:Int!
    var moveNumberBool:Bool!
    var moveOperationBool:Bool!
    
    var numberArray:NSMutableArray!
    
    var backButton:SKSpriteNode!
    var undoButton:SKSpriteNode!
    
    var numberHidden:Int!
    
    var movedAmount:CGFloat!
    
    var labelPos:NSMutableArray!
    var labelPos2:NSMutableArray!
    var operationPos:NSMutableArray!
    var beginNumberPos:CGPoint!
    var beginOperationPos:CGPoint!
    var switchingNumbers:Bool!
    
    var hiddenArray:NSMutableArray!
    
    var gameLogic:GameLogic!
    
    var errorOverlay:SKNode!
    
    var lastOperated:NSMutableArray!
    
    var orientHorizontal:Bool!
    
    var splitTimer:Timer!
    var splitCounter:Int!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size:CGSize) {
        super.init(size: size)
        
        gameLogic = GameLogic()
        
        numberArray = NSMutableArray(capacity: 4)
        numberArray = gameLogic.calculateNumbers2()
        
        lastOperated = NSMutableArray(capacity: 4)
        
        while abs(numberArray[3] as! Int) > 15 {
            numberArray = gameLogic.calculateNumbers2()//stack overflow crash
        }
        
        
        backgroundColor = .init(red: 255/255, green: 255/255, blue: 224/255, alpha: 1)
        
        labelPos = NSMutableArray(capacity: 4)
        labelPos2 = NSMutableArray(capacity: 4)
        operationPos = NSMutableArray(capacity: 4)
        beginNumberPos = CGPoint(x: 0, y: 0)
        beginOperationPos = CGPoint(x: 0, y: 0)
        
        hiddenArray = NSMutableArray(capacity: 4)
        setUpLabelPosArray()
        
        setUpLabels()
        
        
        moveNodeIndex = 0
        moveOperationIndex = 0
        moveNumberBool = false
        moveOperationBool = false
        
        switchingNumbers = false
        
        numberHidden = 0
        
        movedAmount = 0
        
        operation1 = 0
        operation2 = 0
        operation3 = 0
        operation4 = 0
        
        setUpErrorOverlay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch = touches.first?.location(in: self)

        //if touchedNode != nil{
        if gameLogic.checkIfNodeInTouch(node: addSprite, touch: touch!){
            moveOperationIndex = 1
            beginOperationPos = addSprite.position
        }else if gameLogic.checkIfNodeInTouch(node: subtractSprite, touch: touch!){
            moveOperationIndex = 2
            beginOperationPos = subtractSprite.position
        }else if gameLogic.checkIfNodeInTouch(node: multiplySprite, touch: touch!){
            moveOperationIndex = 3
            beginOperationPos = multiplySprite.position
        }else if gameLogic.checkIfNodeInTouch(node: divideSprite, touch: touch!){
            moveOperationIndex = 4
            beginOperationPos = divideSprite.position
        }else{
            moveOperationIndex = 0
        }

        let touchedNode = self.atPoint(touch!)
        
        //if touchedNode != nil{
        let touchedNodeParent = touchedNode.parent
        if touchedNodeParent == firstNumberNode{
            moveNodeIndex = 1
            beginNumberPos = firstNumberNode.position
        }else if touchedNodeParent == secondNumberNode{
            moveNodeIndex = 2
            beginNumberPos = secondNumberNode.position
        }else if touchedNodeParent == thirdNumberNode{
            moveNodeIndex = 3
            beginNumberPos = thirdNumberNode.position
        }else if touchedNodeParent == fourthNumberNode{
            moveNodeIndex = 4
            beginNumberPos = fourthNumberNode.position
        }else{
            moveNodeIndex = 0
        }
        splitCounter = 0
        splitTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { splitTimer in
            if self.hiddenArray.count != 0 && self.moveNodeIndex != 0{
                let node = self.children[self.moveNodeIndex].children[0] as! SKLabelNode
                self.splitCounter! += 1
                if self.splitCounter == 10 {
                    node.fontColor = .init(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
                }else if self.splitCounter > 10{
                    let colorInt = 180-(Double(self.splitCounter)*18)
                    node.fontColor = UIColor.init(red: CGFloat(colorInt/255), green: CGFloat(colorInt/255), blue: CGFloat(colorInt/255), alpha: 1)
                }
                if self.splitCounter == 20{
                    if node == (self.children[self.lastOperated[self.lastOperated.count-1] as! Int] ).children[0]{
                        self.undo()
                    }
                    self.splitCounter = 0
                    node.fontColor = .black
                    self.splitTimer.invalidate()
                }
            }else{
                self.splitTimer.invalidate()
            }
        })
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if movedAmount > self.frame.size.width/10{
            splitCounter = 0
            splitTimer.invalidate()
            if moveNodeIndex != 0{
                let node = self.children[moveNodeIndex].children[0] as! SKLabelNode
                node.fontColor = .black
            }
        }

        var touch = touches.first?.location(in: self.scene!)

        switch moveOperationIndex {
        case 1:
            if (touch?.x)! > beginOperationPos.x && (touch?.x)!-beginOperationPos.x > self.frame.size.width/7{
                moveOperation(right: true)
            }else if (touch?.x)! < beginOperationPos.x && beginOperationPos.x-(touch?.x)! > self.frame.size.width/7{
                moveOperation(right: false)
            }
        case 2:
            if (touch?.x)! > beginOperationPos.x && (touch?.x)!-beginOperationPos.x > self.frame.size.width/7{
                moveOperation(right: true)
            }else if (touch?.x)! < beginOperationPos.x && beginOperationPos.x-(touch?.x)! > self.frame.size.width/7{
                moveOperation(right: false)
            }
        case 3:
            if (touch?.x)! > beginOperationPos.x && (touch?.x)!-beginOperationPos.x > self.frame.size.width/7{
                moveOperation(right: true)
            }else if (touch?.x)! < beginOperationPos.x && beginOperationPos.x-(touch?.x)! > self.frame.size.width/7{
                moveOperation(right: false)
            }
        case 4:
            if (touch?.x)! > beginOperationPos.x && (touch?.x)!-beginOperationPos.x > self.frame.size.width/7{
                moveOperation(right: true)
            }else if (touch?.x)! < beginOperationPos.x && beginOperationPos.x-(touch?.x)! > self.frame.size.width/7{
                moveOperation(right: false)
            }
        default:
            
            
            moveOperationBool = false
            if moveNodeIndex != 0{
                if (touch?.x)! > beginNumberPos.x+self.frame.size.width/2 && (touch?.x)!-beginNumberPos.x+self.frame.size.width/2 > self.frame.size.width/7{
                    switchNumbers(right: true)
                }else if (touch?.x)! < beginNumberPos.x+self.frame.size.width/2 && beginNumberPos.x+self.frame.size.width/2-(touch?.x)! > self.frame.size.width/7{
                    switchNumbers(right: false)
                }
                moveNumberBool = true
            }else{
                moveNumberBool = false
            }
        }
        touch?.x -= self.frame.size.width/2
        touch?.y -= self.frame.size.height/2
        

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        operationTimer.invalidate()
        movedAmount = 0
        splitCounter = 0
        splitTimer.invalidate()
        if moveNodeIndex != 0{
            let node = self.children[moveNodeIndex].children[0] as! SKLabelNode
            node.fontColor = .black
        }
        var touch = touches.first?.location(in: self)
        
        if moveOperationIndex != 0 {
            switch moveOperationIndex {
            case 1:
                if addSprite.position == operationPos.object(at: 0) as! CGPoint{
                    firstOperationMove(node: addSprite)
                }
            case 2:
                if subtractSprite.position == operationPos.object(at: 1) as! CGPoint{
                    firstOperationMove(node: subtractSprite)
                }
            case 3:
                if multiplySprite.position == operationPos.object(at: 2) as! CGPoint{
                    firstOperationMove(node: multiplySprite)
                }
            case 4:
                if divideSprite.position == operationPos.object(at: 3) as! CGPoint{
                    firstOperationMove(node: divideSprite)
                }
            default:
                break
            }
            moveOperationBool = false
        }else{
            let touchedNode = self.atPoint(touch!)
            if gameLogic.checkIfNodeInTouch(node: backButton, touch: touch!){
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let titleScene = TitleScene(size: self.size)
                self.view?.presentScene(titleScene, transition: transition)
            }else if gameLogic.checkIfNodeInTouch(node: undoButton, touch: touch!){
                if hiddenArray.count != 0{
                    undo()
                }else{
                    if !self.children.contains(errorOverlay) {
                        addChild(errorOverlay)
                        errorOverlay.children[0].run(SKAction.fadeAlpha(to: 0.75, duration: 0.25))
                        errorOverlay.children[1].run(SKAction.fadeIn(withDuration: 0.25))
                        delay(1){
                            self.errorOverlay.children[0].run(SKAction.fadeOut(withDuration: 0.25))
                            self.errorOverlay.children[1].run(SKAction.fadeOut(withDuration: 0.25))
                            self.delay(0.25){
                                self.errorOverlay.removeFromParent()
                            }
                        }
                    }

                }
            }
        }
    }
    
}
