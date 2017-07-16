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
            if self.hiddenArray.count != 0 && self.moveNodeIndex != 0 && !self.inUndoProcess && !self.inOperatingAnimation{
                self.drawingLine = true
                self.stillTouching = true
                let node = self.children[self.moveNodeIndex].children[0] as! SKShapeNode
                self.splitCounter! += 1
                if self.splitCounter == 5{
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
                path.move(to: calculatePoint(radius: operationRadius, point: operationPos.object(at: 1) as! CGPoint, numberPos: beginNumberPos))
                path.addLine(to: calculatePoint(radius: numberRadius, point: beginNumberPos, numberPos: beginNumberPos))
                if line1.superlayer == nil && !drawingLine && !inUndoProcess && !switchingNumbers{
                    drawingLine = true
                    number1 = moveNodeIndex
                    line1 = CAShapeLayer()
                    line1.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
                    line1.strokeColor = labelColor.cgColor
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
                }else if line2.superlayer == nil && moveNodeIndex != number1 && !drawingLine && !inUndoProcess && !switchingNumbers{
                    delay(0.25){
                        var node1:SKNode = self.ThirtysixLabel
                        var node2:SKNode = self.ThirtysixLabel
                        var node1Index = 0
                        var node2Index = 0
                        for var i in 6..<10{
                            if i == self.number1+5 {
                                if node1 == self.ThirtysixLabel{
                                    node1 = self.children[self.number1+5]
                                    node1Index = i
                                }else{
                                    node2 = self.children[self.number1+5]
                                    node2Index = i
                                }
                            }else if i == self.number2+5{
                                if node1 == self.ThirtysixLabel{
                                    node1 = self.children[self.number2+5]
                                    node1Index = i
                                }else{
                                    node2 = self.children[self.number2+5]
                                    node2Index = i
                                }
                            }else{
                                self.children[i].run(SKAction.fadeOut(withDuration: 0.25))
                            }
                        }
                        var oldPathPoint = self.calculatePoint(radius: self.numberRadius, point: self.beginNumberPos, numberPos: self.beginNumberPos)
                        let oldNode2Pos = node2.position
                        node2.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 1))
                        var counter = 0
                        let lineUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { lineUpdateTimer in
                            path = UIBezierPath()
                            oldPathPoint.x -= oldNode2Pos.x/100
                            oldPathPoint.y += oldNode2Pos.y/100
                            path.move(to: self.calculatePoint(radius: self.operationRadius, point: self.operationPos.object(at: 1) as! CGPoint, numberPos: node2.position))
                            path.addLine(to: oldPathPoint)
                            self.line2.path = path.cgPath
                            if counter == 70{
                                self.line2.removeAllAnimations()
                                self.line2.removeFromSuperlayer()
                                lineUpdateTimer.invalidate()
                            }else{
                                counter += 1
                            }
                        })
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
        

        if drawingLine{
            drawingLine = false
        }
        
        if switchingNumbers{
            switchingNumbers = false
        }
    }
    
}
