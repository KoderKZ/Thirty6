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
    
    var line1:SKShapeNode!
    var line2:SKShapeNode!
    var number1:Int!
    var number2:Int!
    var drawingLine:Bool!
    
    var stillTouching:Bool!
    var inUndoProcess:Bool!
    
    var viewBackgroundColor:SKColor!
    var labelColor:SKColor!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size:CGSize) {
        super.init(size: size)
        
        gameLogic = GameLogic()
        
        viewBackgroundColor = SKColor(red: 21/255, green: 27/255, blue: 31/255, alpha: 1.0)
        labelColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        
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
        
        backgroundColor = viewBackgroundColor
        
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !drawingLine{
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
            splitTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { splitTimer in
                if self.hiddenArray.count != 0 && self.moveNodeIndex != 0 && !self.inUndoProcess && !self.inOperatingAnimation{
                    self.drawingLine = true
                    self.stillTouching = true
                    let node = self.children[self.moveNodeIndex+7].children[0] as! SKShapeNode
                    self.splitCounter! += 1
                    if self.splitCounter == 10{
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        movedAmount = 0
        if splitCounter > 0{
            splitTimer.invalidate()
            splitCounter = 0
            drawingLine = false
        }
        stillTouching = false
        if !inOperatingAnimation && !inUndoProcess{
            moveOperationBool = false
        }
        if moveNodeIndex != 0{
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
                    let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.0025, repeats: true, block: { lineUpdateTimer in
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
                    let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.0025, repeats: true, block: { lineUpdateTimer in
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
                    delay(0.25){
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
                        node2.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 1))
                        
                        var counter:CGFloat = 0
                        let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { lineUpdateTimer in
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
                        
                        self.delay(1){
                            node2.run(SKAction.move(to: node1.position, duration: 1))
                            var updatePathPoint = self.calculatePoint(radius: self.operationRadius, point: self.operationPos.object(at: 1) as! CGPoint, numberPos: node1.position)
                            var counter = 0
                            let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { lineUpdateTimer in
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
                                        let node1Label = node1.children[1] as! SKLabelNode
                                        let node2Label = node2.children[1] as! SKLabelNode
                                        let number = self.gameLogic.operateNumbers(num1: Int(node1Label.text!)!, num2: Int(node2Label.text!)!, operation: self.operationInt)
                                        NSLog("number1: \(Int(node1Label.text!)!), number2: \(Int(node2Label.text!)!), operation: \(self.operationInt)")
                                        var node1Number = Int(node1Label.text!)!
                                        
                                        let circle = node1.children[0] as! SKShapeNode
                                        let originalCircleColor = circle.fillColor.cgColor
                                        let originalLabelColor = node1Label.fontColor?.cgColor
                                        let redDiff = ((self.labelColor.cgColor.components?[0])!*255-(self.viewBackgroundColor.cgColor.components?[0])!*255)/70
                                        let greenDiff = ((self.labelColor.cgColor.components?[1])!*255-(self.viewBackgroundColor.cgColor.components?[1])!*255)/70
                                        let blueDiff = ((self.labelColor.cgColor.components?[2])!*255-(self.viewBackgroundColor.cgColor.components?[2])!*255)/70
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
                                    lineUpdateTimer.invalidate()
                                }else{
                                    counter += 1
                                }
                            })
                            self.delay(1){
                                node2.alpha = 0
                                node1.removeFromParent()
                                self.insertChild(node1, at: self.number1+7)
                                node2.removeFromParent()
                                self.insertChild(node2, at: self.number2+7)
                                self.hiddenArray.add(self.number2)
                                self.lastOperated.add(self.number1)
                                self.delay(0.3){
                                    let labelPosArray = self.getLabelPosArray()
                                    var moveCounter = 0
                                    moveNodes: for var i in 8..<12{
                                        if !self.hiddenArray.contains(i-7){
                                            self.children[i].run(SKAction.move(to: labelPosArray.object(at: moveCounter) as! CGPoint, duration: 0.1))
                                            moveCounter += 1
                                            if moveCounter == labelPosArray.count{
                                                self.numberHidden! += 1
                                                let node1Label = node1.children[1] as! SKLabelNode
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
                                                break moveNodes
                                            }
                                        }
                                    }
                                }
                                
//                                self.operationInt = 0
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
