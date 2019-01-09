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
    
    var line1:SKShapeNode!
    var line2:SKShapeNode!
    var number1:Int!
    var number2:Int!
    var drawingLine:Bool!
    
    var stillTouching:Bool!
    var inUndoProcess:Bool!
    
    var viewBackgroundColor:SKColor!
    var labelColor:SKColor!
    
    var helpNode:SKNode!
    var tutorialPage:SKNode!
    var inTutorial:Bool!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size:CGSize) {
        super.init(size: size)
        
        gameLogic = GameLogic()
        
        viewBackgroundColor = SKColor(red: 21/255, green: 27/255, blue: 31/255, alpha: 1.0)
        labelColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        
        inTutorial = false
        
        stillTouching = false
        inUndoProcess = false
        
        operation1 = 0
        operation2 = 0
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
        
        backgroundColor = viewBackgroundColor
        
        labelPos = NSMutableArray(capacity: 4)
        labelPos2 = NSMutableArray(capacity: 4)
        operationPos = NSMutableArray(capacity: 4)
        beginNumberPos = CGPoint(x: 0, y: 0)
        beginOperationPos = CGPoint(x: 0, y: 0)
        
        hiddenArray = NSMutableArray(capacity: 4)
        setUpLabelPosArray()
        
        setUpLabels()
        
        setUpTuturialView()
        
        moveNodeIndex = 0
        moveOperationIndex = 0
        moveNumberBool = false
        moveOperationBool = false
        
        switchingNumbers = false
        
        numberHidden = 0
        
        movedAmount = 0
        
        setUpErrorOverlay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !drawingLine && !inTutorial{
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
            if touchedNodeParent?.alpha != 0{
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
            }
            splitCounter = 0
            splitTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { splitTimer in
                if self.hiddenArray.count != 0 && self.moveNodeIndex != 0 && !self.inUndoProcess && !self.inOperatingAnimation{
                    self.drawingLine = true
                    self.stillTouching = true
                    let node = self.children[self.moveNodeIndex+7].children[0] as! SKShapeNode
                    self.splitCounter! += 1
                    if self.splitCounter == 75{
                        var checkIndex = 0
                        switch node.parent!{
                        case self.firstNumberNode:
                            checkIndex = 1
                        case self.secondNumberNode:
                            checkIndex = 2
                        case self.thirdNumberNode:
                            checkIndex = 3
                        case self.fourthNumberNode:
                            checkIndex = 4
                        default:break
                        }
                        if self.lastOperated.contains(checkIndex){
                            self.undo(lastOperatedNode: node.parent!)
                        }
    //                    node.fillColor = self.labelColor
                        self.splitCounter = 0
                        self.splitTimer.invalidate()
                    }
                }else{
                    self.splitTimer.invalidate()
                }
            })
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !inTutorial{
            
            let touch = touches.first?.location(in: self)
            let previousTouch = touches.first?.previousLocation(in: self)
            
            if (touch?.x)! > (previousTouch?.x)!{
                movedAmount! += (touch?.x)!-(previousTouch?.x)!
            }else if (touch?.x)! < (previousTouch?.x)!{
                movedAmount! -= (previousTouch?.x)!-(touch?.x)!
            }
            if movedAmount > self.frame.size.width/7{
                if (touch?.y)! < (operationPos[0] as! CGPoint).y+addSprite.frame.size.height*1.5 &&
                    (touch?.y)! > (operationPos[0] as! CGPoint).y-addSprite.frame.size.height*1.5{
                    operationSwitch(right: true)
                }else if (touch?.y)! < (labelPos[0] as! CGPoint).y+self.frame.size.height/2+firstNumberLabel.frame.size.height*1.5 &&
                    (touch?.y)! > (labelPos[0] as! CGPoint).y+self.frame.size.height/2-firstNumberLabel.frame.size.height*1.5{
                    switchNumbers(right: true)
                }
                movedAmount = 0
            }else if movedAmount < -self.frame.size.width/7{
                if (touch?.y)! < (operationPos[0] as! CGPoint).y+addSprite.frame.size.height*1.5 &&
                    (touch?.y)! > (operationPos[0] as! CGPoint).y-addSprite.frame.size.height*1.5{
                    operationSwitch(right: false)
                }else if (touch?.y)! < (labelPos[0] as! CGPoint).y+self.frame.size.height/2+firstNumberLabel.frame.size.height*1.5 &&
                    (touch?.y)! > (labelPos[0] as! CGPoint).y+self.frame.size.height/2-firstNumberLabel.frame.size.height*1.5{
                    switchNumbers(right: false)
                    
                }
                movedAmount = 0
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first?.location(in: self)
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
        
        movedAmount = 0
        if splitCounter > 0 && !inTutorial{
            splitTimer.invalidate()
            splitCounter = 0
            drawingLine = false
        }
        stillTouching = false
        if !inOperatingAnimation && !inUndoProcess && !inTutorial{
            moveOperationBool = false
        }
        if moveNodeIndex != 0 && !inTutorial{
            switch moveNodeIndex {
            case 1,2,3,4:
                var path = UIBezierPath()
                if line1.alpha == 0 && !drawingLine && !inUndoProcess && !switchingNumbers{
                    path.move(to: calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint, numberPos: beginNumberPos))
                    drawingLine = true
                    inOperatingAnimation = true
                    number1 = moveNodeIndex
                    line1.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    line1.strokeColor = labelColor
                    line1.lineWidth = 2
                    line1.alpha = 1
                    
                    var endPoint = calculatePoint(radius: numberRadius, point: beginNumberPos, numberPos: beginNumberPos)
                    var startPoint = calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint, numberPos: beginNumberPos)
                    var diffPoint = calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint, numberPos: beginNumberPos)
                    diffPoint.x -= endPoint.x
                    diffPoint.y -= endPoint.y
                    var counter = 0
                    let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.00125, repeats: true, block: { lineUpdateTimer in
                        path = UIBezierPath()
                        startPoint.x -= diffPoint.x/100
                        startPoint.y -= diffPoint.y/100
                        path.move(to: self.calculatePoint(radius: self.operationRadius, point: self.operationPos.object(at: 1) as! CGPoint, numberPos: self.beginNumberPos))
                        path.addLine(to: startPoint)
                        self.line1.path = path.cgPath
                        if counter == 100{
                            self.drawingLine = false
                            self.inOperatingAnimation = false
                            lineUpdateTimer.invalidate()
                        }else{
                            counter += 1
                        }
                    })
                }else if moveNodeIndex == number1{
                    var oldPathPoint = calculatePoint(radius: numberRadius, point: beginNumberPos, numberPos: beginNumberPos)
                    let beginLinePos = calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint, numberPos: beginNumberPos)
                    let oldNode2Pos = beginNumberPos
                    var counter:CGFloat = 0
                    let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true, block: { lineUpdateTimer in
                        path = UIBezierPath()
                        oldPathPoint.x -= (oldNode2Pos?.x)!/100
                        oldPathPoint.y -= (oldNode2Pos?.y)!/100
                        path.move(to: beginLinePos)
                        path.addLine(to: oldPathPoint)
                        self.line1.path = path.cgPath
                        
                        if counter == 63{
                            self.line1.alpha = 0
                            lineUpdateTimer.invalidate()
                        }else{
                            counter += 1
                        }
                    })
                    number1 = 0
                }else if moveNodeIndex != number1 && !drawingLine && !inUndoProcess && !switchingNumbers && !inOperatingAnimation{
                    inOperatingAnimation = true
                    drawingLine = true
                    moveOperationBool = true
                    number2 = moveNodeIndex
                    line2.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    line2.strokeColor = labelColor
                    line2.lineWidth = 2
                    line2.alpha = 1
                    
                    path.move(to: calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint, numberPos: beginNumberPos))
                    var endPoint = calculatePoint(radius: numberRadius, point: beginNumberPos, numberPos: beginNumberPos)
                    var startPoint = calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint, numberPos: beginNumberPos)
                    var diffPoint = calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint, numberPos: beginNumberPos)
                    diffPoint.x -= endPoint.x
                    diffPoint.y -= endPoint.y
                    var counter = 0
                    let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.00125, repeats: true, block: { lineUpdateTimer in
                        path = UIBezierPath()
                        startPoint.x -= diffPoint.x/100
                        startPoint.y -= diffPoint.y/100
                        path.move(to: self.calculatePoint(radius: self.operationRadius, point: self.operationPos.object(at: 1) as! CGPoint, numberPos: self.beginNumberPos))
                        path.addLine(to: startPoint)
                        self.line2.path = path.cgPath
                        if counter == 100{
                            lineUpdateTimer.invalidate()
                        }else{
                            counter += 1
                        }
                    })
                    delay(0.13){
                        var node1:SKNode = self.ThirtysixLabel
                        var node2:SKNode = self.ThirtysixLabel
                        for var i in 8..<12{
                            if i == self.number1+7 {
                                if node1 == self.ThirtysixLabel{
                                    node1 = self.children[self.number1+7]
                                }else{
                                    node2 = self.children[self.number1+7]
                                }
                            }else if i == self.number2+7{
                                if node2 == self.ThirtysixLabel{
                                    node2 = self.children[self.number2+7]
                                }else{
                                    node1 = self.children[self.number2+7]
                                }
                            }
                        }
                        if self.number2 > self.number1 {
                            let node2Index = self.children.index(of: node2)!
                            node1.removeFromParent()
                            self.insertChild(node1, at: node2Index)
                        }
                        var oldPathPoint = self.calculatePoint(radius: self.numberRadius, point: self.beginNumberPos, numberPos: self.beginNumberPos)
                        let beginLinePos = self.calculatePoint(radius: self.operationRadius, point: self.operationPos.object(at: 1) as! CGPoint, numberPos: node2.position)
                        let oldNode2Pos = node2.position
                        node2.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.5))
                        
                        var counter:CGFloat = 0
                        let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true, block: { lineUpdateTimer in
                            path = UIBezierPath()
                            oldPathPoint.x -= oldNode2Pos.x/100
                            oldPathPoint.y -= oldNode2Pos.y/100
                            path.move(to: beginLinePos)
                            path.addLine(to: oldPathPoint)
                            self.line2.path = path.cgPath
                            
                            if counter == 70{
                                self.line2.alpha = 0
                                lineUpdateTimer.invalidate()
                            }else{
                                counter += 1
                            }
                        })
                        self.delay(0.5){
                            node2.run(SKAction.move(to: node1.position, duration: 0.5))
                            var updatePathPoint = self.calculatePoint(radius: self.operationRadius, point: self.operationPos.object(at: 1) as! CGPoint, numberPos: node1.position)
                            var counter = 0
                            let node1Label = node1.children[1] as! SKLabelNode
                            let node2Label = node2.children[1] as! SKLabelNode
                            let number = self.gameLogic.operateNumbers(num1: Int(node1Label.text!)!, num2: Int(node2Label.text!)!, operation: self.operationInt)
                            var node1Number = Int(node1Label.text!)!
                            let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true, block: { lineUpdateTimer in
                                path = UIBezierPath()
                                updatePathPoint.x += node1.position.x/100
                                updatePathPoint.y += node1.position.y/100
                                path.move(to: updatePathPoint)
                                path.addLine(to: self.calculatePoint(radius: self.numberRadius, point: node1.position, numberPos: node1.position))
                                self.line1.path = path.cgPath
                                if counter == 65{
                                    self.line1.alpha = 0
                                    self.drawingLine = false
                                    self.inOperatingAnimation = false
                                    self.delay(0.25){
                                        if number == -1{
                                            let overlay = self.errorOverlay.children[0]
                                            let message = self.errorOverlay.children[3]
                                            overlay.run(SKAction.fadeIn(withDuration: 0.2))
                                            message.run(SKAction.fadeIn(withDuration: 0.2))
                                            self.numberHidden! -= 1
                                            self.delay(1){
                                                let overlay = self.errorOverlay.children[0]
                                                let message = self.errorOverlay.children[3]
                                                overlay.run(SKAction.fadeOut(withDuration: 0.25))
                                                message.run(SKAction.fadeOut(withDuration: 0.25))
                                            }
                                        }else{
                                            let circle = node1.children[0] as! SKShapeNode
                                            let originalCircleColor = circle.fillColor.cgColor
                                            let originalLabelColor = node1Label.fontColor?.cgColor
                                            
                                            let x1 = (self.labelColor.cgColor.components?[0])!*255
                                            let x2 = (self.labelColor.cgColor.components?[1])!*255
                                            let x3 = (self.labelColor.cgColor.components?[2])!*255
                                            
                                            let redDiff = (x1-(self.viewBackgroundColor.cgColor.components?[0])!*255)/70
                                            let greenDiff = (x2-(self.viewBackgroundColor.cgColor.components?[1])!*255)/70
                                            let blueDiff = (x3-(self.viewBackgroundColor.cgColor.components?[2])!*255)/70
                                            var counter:CGFloat = 0
                                            if !self.lastOperated.contains(self.number1){
                                                let colorUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.0025, repeats: true, block: { lineUpdateTimer in
                                                    if counter <= 70{
                                                        circle.fillColor = SKColor(colorLiteralRed: Float(originalCircleColor.components![0]*255+(redDiff*counter))/255, green: Float(originalCircleColor.components![1]*255+(greenDiff*counter))/255, blue: Float(originalCircleColor.components![2]*255+(blueDiff*counter))/255, alpha: 1)
                                                    
                                                        node1Label.fontColor = SKColor(colorLiteralRed: Float((originalLabelColor?.components![0])!*255-redDiff*counter)/255, green: Float((originalLabelColor?.components![1])!*255-greenDiff*counter)/255, blue: Float((originalLabelColor?.components![2])!*255-blueDiff*counter)/255, alpha: 1)
                                                        counter += 1
                                                    }

                                                })
                                                self.delay(1.75){
                                                    colorUpdateTimer.invalidate()
                                                }
                                            }

                                            let wait = SKAction.wait(forDuration: 0.05)
                                            let block = SKAction.run({
                                                switch self.operationInt{
                                                case 1,3:
                                                    node1Label.text = "\(node1Number + 1)"
                                                    node1Number += 1
                                                case 2,4:
                                                    node1Label.text = "\(node1Number - 1)"
                                                    node1Number -= 1
                                                default:break
                                                }

                                                
                                            })
                                            let sequence = SKAction.sequence([wait, block])
                                            if self.operationInt == 1 || self.operationInt == 3{
                                                node1Label.run(SKAction.repeat(sequence, count: abs(number-node1Number)))
                                            }else if self.operationInt == 2 || self.operationInt == 4{
                                                node1Label.run(SKAction.repeat(sequence, count: node1Number-number))
                                            }
                                        }
                                    }
                                    lineUpdateTimer.invalidate()
                                }else{
                                    counter += 1
                                }
                            })
                            self.delay((Double(abs(node1Number-number))*0.05)+0.5){
                                if number != -1{
                                    node2.alpha = 0
                                    node1.removeFromParent()
                                    self.insertChild(node1, at: self.number1+7)
                                    node2.removeFromParent()
                                    self.insertChild(node2, at: self.number2+7)
                                    self.hiddenArray.add(self.number2)
                                }
                                self.delay(0.3){
                                    let labelPosArray = self.getLabelPosArray()
                                    var moveCounter = 0
                                    moveNodes: for var i in 8..<12{
                                        if !self.hiddenArray.contains(i-7){
                                            self.children[i].run(SKAction.move(to: labelPosArray.object(at: moveCounter) as! CGPoint, duration: 0.1))
                                            moveCounter += 1
                                            if moveCounter == labelPosArray.count{
                                                self.numberHidden! += 1
                                                switch self.numberHidden!{
                                                case 1:
                                                    self.operation1 = self.operationInt
                                                case 2:
                                                    self.operation2 = self.operationInt
                                                default:break
                                                }
                                                let node1Label = node1.children[1] as! SKLabelNode
                                                    if self.numberHidden == 3 && node1Label.text == "36"{
                                                        self.delay(0.5){
                                                            let opCircle = self.children[1]
                                                            self.addSprite.run(SKAction.fadeOut(withDuration: 0.25))
                                                            self.subtractSprite.run(SKAction.fadeOut(withDuration: 0.25))
                                                            self.multiplySprite.run(SKAction.fadeOut(withDuration: 0.25))
                                                            self.divideSprite.run(SKAction.fadeOut(withDuration: 0.25))
                                                            opCircle.run(SKAction.fadeOut(withDuration: 0.25))
                                                            self.delay(0.3){
                                                                node1.run(SKAction.move(to: CGPoint(x:0,y:0), duration: 0.5))
                                                                var node1Circle = node1.children[0] as! SKShapeNode
                                                                let wait = SKAction.wait(forDuration: 0.02)
                                                                let block = SKAction.run({
                                                                    node1Label.fontSize += 1
                                                                    let numCircle = SKShapeNode(circleOfRadius: node1Label.frame.size.height*4/5)
                                                                    numCircle.fillColor = self.labelColor
                                                                    numCircle.lineWidth = 1
                                                                    numCircle.strokeColor = self.labelColor
                                                                    numCircle.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
                                                                    node1Circle.removeFromParent()
                                                                    node1.insertChild(numCircle, at: 0)
                                                                })
                                                                let sequence = SKAction.sequence([wait, block])
                                                                node1Label.run(SKAction.repeat(sequence, count: 22))
                                                                self.delay(0.6){
                                                                    self.ThirtysixLabel.removeFromParent()
                                                                    self.addChild(self.ThirtysixLabel)
                                                                    self.ThirtysixLabel.run(SKAction.move(to: CGPoint(x:self.frame.size.width/2,y:self.frame.size.height/2), duration: 0.5))
                                                                    self.delay(0.52){
                                                                        node1Label.alpha = 0
                                                                    }
                                                                    self.delay(1){
                                                                        node1.run(SKAction.fadeOut(withDuration: 0.3))
                                                                        self.ThirtysixLabel.run(SKAction.fadeOut(withDuration: 0.3))
                                                                        self.delay(1){
                                                                            self.endGame()
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }else if self.numberHidden == 3 && node1Label.text != "36"{
                                                        self.delay(0.5){
                                                            let overlay = self.errorOverlay.children[0]
                                                            let message = self.errorOverlay.children[2]
                                                            overlay.run(SKAction.fadeIn(withDuration: 0.2))
                                                            message.run(SKAction.fadeIn(withDuration: 0.2))
                                                            self.delay(0.2){
                                                                self.reset()
                                                                self.delay(1){
                                                                    overlay.run(SKAction.fadeOut(withDuration: 0.25))
                                                                    message.run(SKAction.fadeOut(withDuration: 0.25))
                                                                }
                                                            }
                                                        }
                                                    }
                                                self.lastOperated.add(self.number1)
                                                break moveNodes
                                            }
                                        }
                                    }
                                }
//                                self.operationInt = 0
                            }
                        }
                    }
                    moveOperationBool = false
                }
            default:
                break
            }
            
            
        }
        
        if moveOperationIndex != 0{

        }else{
            let touchedNode = self.atPoint(touch!)
            if gameLogic.checkIfNodeInTouch(node: backButton, touch: touch!, multiplier: 1.5){
                line1.alpha = 0
                line2.alpha = 0
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let titleScene = TitleScene(size: self.size)
                self.view?.presentScene(titleScene, transition: transition)
            }
        }
        

        if drawingLine && !inOperatingAnimation{
            drawingLine = false
        }
        
        if switchingNumbers{
            switchingNumbers = false
        }
    }
    
}
