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
    var operationInt:Int!
    
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
    var numberHidden:Int!
    
    var movedAmount:CGFloat!
    
    var labelPos:NSMutableArray!
    var labelPos2:NSMutableArray!
    var operationPos:NSMutableArray!
    var beginNumberPos:CGPoint!
    var beginOperationPos:CGPoint!
    var switchingNumbers:Bool!
    var operationRadius:CGFloat!
    var numberRadius:CGFloat!
    
    var hiddenArray:NSMutableArray!
    
    var gameLogic:GameLogic!
    
    var errorOverlay:SKNode!
    
    var lastOperated:NSMutableArray!
    
    var orientHorizontal:Bool!
    
    var splitTimer:Timer!
    var splitCounter:Int!
    
    var inOperatingAnimation:Bool!
    
    var line1:CAShapeLayer!
    var line2:CAShapeLayer!
    var number1:Int!
    var number2:Int!
    var drawingLine:Bool!
    
    var stillTouching:Bool!
    var inUndoProcess:Bool!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size:CGSize) {
        super.init(size: size)
        
        gameLogic = GameLogic()
        
        stillTouching = false
        inUndoProcess = false
        
        operation1 = 0
        operation2 = 0
        operation3 = 0
        operation4 = 0
        operationInt = 1
        number1 = 0
        number2 = 0
        drawingLine = false
        
        numberArray = NSMutableArray(capacity: 4)
        numberArray = gameLogic.calculateNumbers2()
        
        inOperatingAnimation = false
        
        lastOperated = NSMutableArray(capacity: 4)
        
        while abs(numberArray[3] as! Int) > 15 {
            numberArray = gameLogic.calculateNumbers2()
        }
        
        //SKColor(red: 53/255, green: 53/255, blue: 50/255, alpha: 1.0)
        backgroundColor = SKColor(red: 21/255, green: 27/255, blue: 31/255, alpha: 1.0)
        
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
        
        setUpErrorOverlay()
        
        line1 = CAShapeLayer()
        line2 = CAShapeLayer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch = touches.first?.location(in: self)

        stillTouching = true
        
        //if touchedNode != nil{
        if gameLogic.checkIfNodeInTouch(node: addSprite, touch: touch!, multiplier: 2){
            moveOperationIndex = 1
            beginOperationPos = addSprite.position
        }else if gameLogic.checkIfNodeInTouch(node: subtractSprite, touch: touch!, multiplier: 2){
            moveOperationIndex = 2
            beginOperationPos = subtractSprite.position
        }else if gameLogic.checkIfNodeInTouch(node: multiplySprite, touch: touch!, multiplier: 2){
            moveOperationIndex = 3
            beginOperationPos = multiplySprite.position
        }else if gameLogic.checkIfNodeInTouch(node: divideSprite, touch: touch!, multiplier: 2){
            moveOperationIndex = 4
            beginOperationPos = divideSprite.position
        }else{
            moveOperationIndex = 0
        }

        let touchedNode = self.atPoint(touch!)
        
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
                self.drawingLine = true
                self.stillTouching = true
                let node = self.children[self.moveNodeIndex].children[0] as! SKLabelNode
                self.splitCounter! += 1
                if self.splitCounter == 10 {
                    node.fontColor = .black
                }else if self.splitCounter > 10{
                    let colorInt1 = (Double(self.splitCounter-10)*17.6)
                    let colorInt2 = (Double(self.splitCounter-10)*19.6)
                    let colorInt3 = (Double(self.splitCounter-10)*22.2)
                    node.fontColor = UIColor.init(red: CGFloat(colorInt1/255), green: CGFloat(colorInt2/255), blue: CGFloat(colorInt3/255), alpha: 1)
                }
                if self.splitCounter == 20{
                    var checkIndex = 0
                    switch node{
                    case self.firstNumberLabel:
                        checkIndex = 1
                    case self.secondNumberLabel:
                        checkIndex = 2
                    case self.thirdNumberLabel:
                        checkIndex = 3
                    case self.fourthNumberLabel:
                        checkIndex = 4
                    default:break
                    }
                    if self.lastOperated.contains(checkIndex){
                        self.undo(lastOperatedNode: node.parent!)
                    }
                    node.fontColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
                    self.splitTimer.invalidate()
                }
            }else{
                self.splitTimer.invalidate()
                self.drawingLine = false
            }
        })
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        let touch = touches.first?.location(in: self)
        let previousTouch = touches.first?.previousLocation(in: self)
        
        if (touch?.x)! > (previousTouch?.x)!{
            movedAmount! += (touch?.x)!-(previousTouch?.x)!
        }else if (touch?.x)! < (previousTouch?.x)!{
            movedAmount! -= (previousTouch?.x)!-(touch?.x)!
        }
        if movedAmount > self.frame.size.width/7{
            operationSwitch(right: true)
            movedAmount = 0
        }else if movedAmount < -self.frame.size.width/7{
            operationSwitch(right: false)
            movedAmount = 0
        }
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        movedAmount = 0
        splitTimer.invalidate()
        splitCounter = 0
        stillTouching = false
        if !inOperatingAnimation && !inUndoProcess{
            drawingLine = false
            moveOperationBool = false
        }
        if moveNodeIndex != 0{
            switch moveNodeIndex {
            case 1,2,3,4:
                let path = UIBezierPath()
                path.move(to: calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint))
                path.addLine(to: calculatePoint(radius: numberRadius, point: beginNumberPos))
                if line1.superlayer == nil && !drawingLine && !inUndoProcess{
                    drawingLine = true
                    number1 = moveNodeIndex
                    line1 = CAShapeLayer()
                    line1.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
                    line1.strokeColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0).cgColor
                    line1.lineWidth = 2
                    line1.path = path.cgPath
                    
                    view?.layer.addSublayer(line1)
                    let animation = CABasicAnimation(keyPath: "strokeEnd")
                    animation.fromValue = 0
                    animation.duration = 0.25
                    line1.add(animation, forKey: "MyAnimation")
                    delay(0.25){
                        self.drawingLine = false
                    }
                }else if line2.superlayer == nil && moveNodeIndex != number1 && !drawingLine && !inUndoProcess{
                    inOperatingAnimation = true
                    drawingLine = true
                    moveOperationBool = true
                    number2 = moveNodeIndex
                    line2 = CAShapeLayer()
                    line2.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
                    line2.strokeColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0).cgColor
                    line2.lineWidth = 2
                    line2.path = path.cgPath
                    
                    view?.layer.addSublayer(line2)
                    let animation = CABasicAnimation(keyPath: "strokeEnd")
                    animation.fromValue = 0
                    animation.duration = 0.25
                    line2.add(animation, forKey: "MyAnimation")
                    

                    
                    delay(0.25){
                        var node1:SKNode = self.ThirtysixLabel
                        var node2:SKNode = self.ThirtysixLabel
                        var node1Index = 0
                        var node2Index = 0
                        for var i in 1..<5{
                            if i == self.number1 {
                                if node1 == self.ThirtysixLabel{
                                    node1 = self.children[self.number1]
                                    node1Index = i
                                }else{
                                    node2 = self.children[self.number1]
                                    node2Index = i
                                }
                            }else if i == self.number2{
                                if node1 == self.ThirtysixLabel{
                                    node1 = self.children[self.number2]
                                    node1Index = i
                                }else{
                                    node2 = self.children[self.number2]
                                    node2Index = i
                                }
                            }else{
                                self.children[i].run(SKAction.fadeOut(withDuration: 0.25))
                            }
                        }
                        if node1.position.x > node2.position.x {
                            let tempNode = node1
                            node1 = node2
                            node2 = tempNode
                            node2Index = node1Index
                        }
                        self.line1.strokeColor = SKColor.clear.cgColor
                        self.line2.strokeColor = SKColor.clear.cgColor
                        self.delay(0.25){
                            self.line1.removeAllAnimations()
                            self.line2.removeAllAnimations()
                            node1.run(SKAction.move(to: self.labelPos.object(at: 0) as! CGPoint, duration: 0.5))
                            node2.run(SKAction.move(to: self.labelPos.object(at: 3) as! CGPoint, duration: 0.5))
                            var operationNode = SKSpriteNode()
                            
                            switch self.operationInt {
                            case 1:
                                operationNode = self.addSprite
                            case 2:
                                operationNode = self.subtractSprite
                            case 3:
                                operationNode = self.multiplySprite
                            case 4:
                                operationNode = self.divideSprite
                            default:
                                break
                            }
                            let operationNodeNewPos = CGPoint(x: self.frame.size.width/2, y:self.frame.size.height/4)
                            operationNode.run(SKAction.move(to: operationNodeNewPos, duration: 0.5))
                            self.delay(0.75){
                                node1.run(SKAction.moveTo(x: 0, duration: 0.5))
                                node2.run(SKAction.moveTo(x: 0, duration: 0.5))
                                node1.run(SKAction.fadeOut(withDuration: 0.4))
                                node2.run(SKAction.fadeOut(withDuration: 0.4))
                                
                                let node1Label = node1.children[0] as! SKLabelNode
                                let node2Label = node2.children[0] as! SKLabelNode
                                
                                let int1 = Int(node1Label.text!)!
                                let int2 = Int(node2Label.text!)!
                                
                                let operatedNumber = self.gameLogic.operateNumbers(num1: int1, num2: int2, operation: self.operationInt)
                                

                                
                                operationNode.run(SKAction.fadeOut(withDuration: 0.5))
                                self.delay(0.5){
                                    operationNode.position = self.operationPos.object(at: 1) as! CGPoint
                                    operationNode.run(SKAction.fadeIn(withDuration: 0.2))
                                    var labelPosArray = self.getLabelPosArray()
                                    if operatedNumber == -1{
                                        self.addChild(self.errorOverlay)
                                        let overlay = self.errorOverlay.children[0]
                                        let message = self.errorOverlay.children[3]
                                        overlay.run(SKAction.fadeIn(withDuration: 0.2))
                                        message.run(SKAction.fadeIn(withDuration: 0.2))
                                        self.numberHidden! -= 1
                                        labelPosArray = self.getLabelPosArray()
                                        self.delay(0.2){
                                            node1.run(SKAction.move(to: labelPosArray.object(at: labelPosArray.count-1) as! CGPoint, duration: 0.01))
                                            node2.run(SKAction.move(to: labelPosArray.object(at: labelPosArray.count-2) as! CGPoint, duration: 0.01))
                                            node2.alpha = 1
                                            node1.alpha = 1
                                        }
                                    }else{
                                        node1.run(SKAction.move(to: labelPosArray.object(at: labelPosArray.count-1) as! CGPoint, duration: 0.01))
                                        node1.run(SKAction.fadeIn(withDuration: 0.2))
                                        node1Label.text = "\(operatedNumber)"
                                        self.hiddenArray.add(node2Index)
                                        self.lastOperated.add(node1Index)
                                        switch node2Index {
                                        case 1:
                                            self.operation1 = self.operationInt
                                        case 2:
                                            self.operation2 = self.operationInt
                                        case 3:
                                            self.operation3 = self.operationInt
                                        case 4:
                                            self.operation4 = self.operationInt
                                        default:
                                            break
                                        }
                                    }
                                    self.delay(0.4){
                                        if operatedNumber == -1{
                                            self.delay(1){
                                                let overlay = self.errorOverlay.children[0]
                                                let message = self.errorOverlay.children[3]
                                                overlay.run(SKAction.fadeOut(withDuration: 0.25))
                                                message.run(SKAction.fadeOut(withDuration: 0.25))
                                                self.delay(0.25){
                                                    self.errorOverlay.removeFromParent()
                                                }
                                            }
                                        }
                                        var revealCounter = 0
                                        revealHiddenNumbers: for var i in 1..<5{
                                            if self.numberHidden == 2 && operatedNumber != -1{
                                                break revealHiddenNumbers
                                            }else if operatedNumber == -1{
                                                if revealCounter+2 == labelPosArray.count{
                                                    break revealHiddenNumbers
                                                }
                                            }else{
                                                if revealCounter+1 == labelPosArray.count{
                                                    break revealHiddenNumbers
                                                }
                                            }
                                            if i != self.number1 && i != self.number2 && !self.hiddenArray.contains(self.children[i]){
                                                self.children[i].position = labelPosArray.object(at: revealCounter) as! CGPoint
                                                self.children[i].run(SKAction.fadeIn(withDuration: 0.3))
                                                revealCounter += 1
                                            }
                                        }
                                        self.drawingLine = false
                                        self.moveOperationBool = false
                                        self.numberHidden! += 1
                                        self.line1.removeFromSuperlayer()
                                        self.line2.removeFromSuperlayer()
                                        self.delay(0.3){
                                            self.inOperatingAnimation = false
                                        }
                                        if self.numberHidden == 3 && node1Label.text == "36"{
                                            self.delay(0.5){
                                                self.endGame()
                                            }
                                        }else if self.numberHidden == 3 && node1Label.text != "36"{
                                            self.delay(0.5){
                                                self.addChild(self.errorOverlay)
                                                let overlay = self.errorOverlay.children[0]
                                                let message = self.errorOverlay.children[2]
                                                overlay.run(SKAction.fadeIn(withDuration: 0.2))
                                                message.run(SKAction.fadeIn(withDuration: 0.2))
                                                self.delay(0.2){
                                                    self.reset()
                                                    self.delay(1){
                                                        overlay.run(SKAction.fadeOut(withDuration: 0.25))
                                                        message.run(SKAction.fadeOut(withDuration: 0.25))
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
                        }
                    }
                }
                
                
            default:
                break
            }
            
            
        }
        var touch = touches.first?.location(in: self)
        
        if moveOperationIndex != 0{

        }else{
            let touchedNode = self.atPoint(touch!)
            if gameLogic.checkIfNodeInTouch(node: backButton, touch: touch!, multiplier: 1.5){
                line1.removeAllAnimations()
                line2.removeAllAnimations()
                line1.removeFromSuperlayer()
                line2.removeFromSuperlayer()
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let titleScene = TitleScene(size: self.size)
                self.view?.presentScene(titleScene, transition: transition)
            }
        }
        

        if drawingLine == true{
            drawingLine = false
        }
        
    }
    
}
