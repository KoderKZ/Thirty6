//
//  GameElements.swift
//  Thirty6
//
//  Created by Kevin Zhou on 3/30/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit


extension GameScene {

    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func setUpLabelPosArray(){
        labelPos.add(CGPoint(x: -self.frame.size.width/8*3, y: -self.frame.size.height/4))
        labelPos.add(CGPoint(x: -self.frame.size.width/8, y: -self.frame.size.height/4))
        labelPos.add(CGPoint(x: self.frame.size.width/8, y: -self.frame.size.height/4))
        labelPos.add(CGPoint(x: self.frame.size.width/8*3, y: -self.frame.size.height/4))
        
        operationPos.add(CGPoint(x: self.frame.size.width/3, y: self.frame.size.height/2))
        operationPos.add(CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2))
        operationPos.add(CGPoint(x: self.frame.size.width/3*2, y: self.frame.size.height/2))
        
        labelPos2.add(CGPoint(x: -self.frame.size.width/4, y: -self.frame.size.height/4))
        labelPos2.add(CGPoint(x: 0, y: -self.frame.size.height/4))
        labelPos2.add(CGPoint(x: self.frame.size.width/4, y: -self.frame.size.height/4))
    }
    
    func reset() {
        hiddenArray.removeAllObjects()
        lastOperated.removeAllObjects()
        numberHidden = 0
        
        firstNumberLabel.text = "\(numberArray[0])"
        secondNumberLabel.text = "\(numberArray[1])"
        thirdNumberLabel.text = "\(numberArray[2])"
        fourthNumberLabel.text = "\(numberArray[3])"
        
        operation1 = 0
        operation2 = 0
        operation3 = 0
        operation4 = 0
        operationInt = 1
        
        for var i in 1..<5{
            self.children[i].position = labelPos.object(at: i-1) as! CGPoint
            self.children[i].alpha = 1
        }
        
        let width1 = firstNumberLabel.frame.size.height*0.5
        let width2 = firstNumberLabel.frame.size.height
        
        addSprite.position = operationPos.object(at: 1) as! CGPoint
        addSprite.size = CGSize(width: width2, height: width2)
        
        subtractSprite.position = operationPos.object(at: 2) as! CGPoint
        subtractSprite.size = CGSize(width: width1, height: width1/100*15)
        
        multiplySprite.alpha = 0
        
        divideSprite.position = operationPos.object(at: 0) as! CGPoint
        divideSprite.size = CGSize(width: width1, height: width1)
        
        
    }

    func setUpErrorOverlay() {
        errorOverlay = SKNode()
        errorOverlay.position = CGPoint(x: 0, y: 0)
        
        let errorOverlayScreen = SKSpriteNode()
        errorOverlayScreen.size = self.size
        errorOverlayScreen.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        errorOverlayScreen.color = .black
        errorOverlayScreen.alpha = 0
        
        let undoMessage = SKLabelNode(text: "Cannot Undo!")
        undoMessage.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/3*2)
        undoMessage.horizontalAlignmentMode = .center
        undoMessage.verticalAlignmentMode = .center
        undoMessage.fontSize = 40
        undoMessage.fontColor = .white
        undoMessage.alpha = 0
        
        let endMessage = SKLabelNode(text: "Try again!")
        endMessage.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/3*2)
        endMessage.horizontalAlignmentMode = .center
        endMessage.verticalAlignmentMode = .center
        endMessage.fontSize = 40
        endMessage.fontColor = .white
        endMessage.alpha = 0
        
        let operationMessage = SKLabelNode(text: "Cannot do that!")
        operationMessage.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/3*2)
        operationMessage.horizontalAlignmentMode = .center
        operationMessage.verticalAlignmentMode = .center
        operationMessage.fontSize = 40
        operationMessage.fontColor = .white
        operationMessage.alpha = 0
        
        errorOverlay.addChild(errorOverlayScreen)
        errorOverlay.addChild(undoMessage)
        errorOverlay.addChild(endMessage)
        errorOverlay.addChild(operationMessage)
    }
    
    func calculatePoint(radius:CGFloat, point:CGPoint) -> CGPoint{
        var returnPoint = CGPoint()
        
        var modifier:CGFloat = 0
        
        if point.y == firstNumberNode.position.y {
            modifier = -1
        }else{
            modifier = 1
        }

        
        let operationPoint = operationPos.object(at: 1) as! CGPoint
        let numberPos = CGPoint(x: beginNumberPos.x+self.frame.size.width/2, y: beginNumberPos.y+self.frame.size.height/2)
        let aSquared = (operationPoint.x-numberPos.x) * (operationPoint.x-numberPos.x)
        let bSquared = (operationPoint.y-numberPos.y) * (operationPoint.y-numberPos.y)
        let c = sqrt(aSquared+bSquared)
        let expression = (operationPoint.x-numberPos.x)*radius/c
        let x = point.x-(modifier*expression)
        let y = point.y+(modifier*((operationPoint.y-numberPos.y)*radius/c))
        
        returnPoint = CGPoint(x: x, y: y)
        
        if point == beginNumberPos{
            returnPoint.y += self.frame.size.height
            returnPoint.x += self.frame.size.width/2
        }
        
        return returnPoint
    }
    
    func createNumLabel(num: Int) -> SKNode {

        
        let numLabelNode = SKNode()
        
        let numLabel = SKLabelNode(text: "\(numberArray[num])")
        numLabel.fontSize = 50
        numLabel.fontName = "TimeBurner-Bold"
        numLabel.fontColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        numLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        numLabel.horizontalAlignmentMode = .center
        numLabel.verticalAlignmentMode = .center
        numLabelNode.addChild(numLabel)
        
        numberRadius = numLabel.frame.size.height*4/5
        
        let circlePath = UIBezierPath.init(arcCenter: numLabelNode.position, radius: numberRadius, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: false)
//        let circleShape = CAShapeLayer()
//        circleShape.path = circlePath.cgPath
//        circleShape.fillColor = SKColor.clear.cgColor
//        circleShape.strokeColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0).cgColor
//        circleShape.lineWidth = 2
//        self.view?.layer.mask = circleShape
        
        let numCircle = SKShapeNode()
        numCircle.path = circlePath.cgPath
        numCircle.fillColor = .clear
        numCircle.lineWidth = 3
        numCircle.strokeColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        numCircle.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        numLabelNode.addChild(numCircle)

        
        
        return numLabelNode
    }
    
    
    func setUpLabels(){
        ThirtysixLabel = SKLabelNode(text: "36")
        ThirtysixLabel.fontSize = 75
        ThirtysixLabel.fontName = "TimeBurner-Bold"
        ThirtysixLabel.fontColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        ThirtysixLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/4*3)
        ThirtysixLabel.horizontalAlignmentMode = .center
        ThirtysixLabel.verticalAlignmentMode = .center
        addChild(ThirtysixLabel)
        
        firstNumberNode = createNumLabel(num: 0)
        firstNumberNode.position = labelPos.object(at: 0) as! CGPoint
        addChild(firstNumberNode)
        
        secondNumberNode = createNumLabel(num: 1)
        secondNumberNode.position = labelPos.object(at: 1) as! CGPoint
        addChild(secondNumberNode)
        
        thirdNumberNode = createNumLabel(num: 2)
        thirdNumberNode.position = labelPos.object(at: 2) as! CGPoint
        addChild(thirdNumberNode)
        
        fourthNumberNode = createNumLabel(num: 3)
        fourthNumberNode.position = labelPos.object(at: 3) as! CGPoint
        addChild(fourthNumberNode)
        
        firstNumberLabel = firstNumberNode.children[0] as! SKLabelNode
        secondNumberLabel = secondNumberNode.children[0] as! SKLabelNode
        thirdNumberLabel = thirdNumberNode.children[0] as! SKLabelNode
        fourthNumberLabel = fourthNumberNode.children[0] as! SKLabelNode
        
        let width1 = firstNumberLabel.frame.size.height*0.5
        let width2 = firstNumberLabel.frame.size.height
        
        addSprite = SKSpriteNode(imageNamed: "add.png")
        addSprite.position = operationPos.object(at: 1) as! CGPoint
        addSprite.color = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        addSprite.colorBlendFactor = 1
        addSprite.size = CGSize(width: width2, height: width2)
        
        subtractSprite = SKSpriteNode(imageNamed: "subtract.png")
        subtractSprite.position = operationPos.object(at: 2) as! CGPoint
        subtractSprite.color = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        subtractSprite.colorBlendFactor = 1
        subtractSprite.size = CGSize(width: width1, height: width1/100*15)
        
        multiplySprite = SKSpriteNode(imageNamed: "multiply.png")
        multiplySprite.color = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        multiplySprite.colorBlendFactor = 1
        multiplySprite.size = CGSize(width: width1, height: width1)
        multiplySprite.alpha = 0
        
        divideSprite = SKSpriteNode(imageNamed: "divide.png")
        divideSprite.position = operationPos.object(at: 0) as! CGPoint
        divideSprite.color = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        divideSprite.colorBlendFactor = 1
        divideSprite.size = CGSize(width: width1, height: width1)
        
        addChild(addSprite)
        addChild(subtractSprite)
        addChild(divideSprite)
        addChild(multiplySprite)
        
        operationRadius = addSprite.frame.size.width/5*4
        
        let circle = SKShapeNode(circleOfRadius: operationRadius)
        circle.fillColor = .clear
        circle.lineWidth = 7
        circle.strokeColor = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        circle.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        addChild(circle)
        
        
        backButton = SKSpriteNode(imageNamed: "backButton.png")
        backButton.size = CGSize(width: 10, height: 25)
        backButton.color = SKColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0)
        backButton.colorBlendFactor = 1
        backButton.position = CGPoint(x: backButton.size.width*3, y: self.frame.size.height-(backButton.size.height*2.5))
        addChild(backButton)

    }
    
    func endGame() {
        let transition = SKTransition.flipVertical(withDuration: 0.5)
        let endScene = EndGame(size: self.size)
        self.view?.presentScene(endScene, transition: transition)
    }
    
    func operationSwitch(right: Bool) {
        if !moveOperationBool{
            moveOperationBool = true
            var node1 = SKSpriteNode()
            var node2 = SKSpriteNode()
            var node3 = SKSpriteNode()
            var node4 = SKSpriteNode()
            
            switch operationInt {
            case 1:
                node1 = addSprite
                node4 = multiplySprite
                if right {
                    node2 = subtractSprite
                    node3 = divideSprite
                }else{
                    node2 = divideSprite
                    node3 = subtractSprite
                }
            case 2:
                node1 = subtractSprite
                node4 = divideSprite
                if right {
                    node2 = multiplySprite
                    node3 = addSprite
                }else{
                    node2 = addSprite
                    node3 = multiplySprite
                }
            case 3:
                node1 = multiplySprite
                node4 = addSprite
                if right {
                    node2 = divideSprite
                    node3 = subtractSprite
                }else{
                    node2 = subtractSprite
                    node3 = divideSprite
                }
            case 4:
                node1 = divideSprite
                node4 = subtractSprite
                if right {
                    node2 = addSprite
                    node3 = multiplySprite
                }else{
                    node2 = multiplySprite
                    node3 = addSprite
                }
            default:
                break
            }
            
            if !right{
                node1.run(SKAction.move(to: operationPos.object(at: 0) as! CGPoint, duration: 0.25))
                node2.run(SKAction.fadeOut(withDuration: 0.25))
                node2.run(SKAction.moveTo(x: self.frame.size.width/6, duration: 0.25))
                node3.run(SKAction.move(to: operationPos.object(at: 1) as! CGPoint, duration: 0.25))
                
                var size1 = CGSize(width: firstNumberLabel.frame.size.height*0.5, height: firstNumberLabel.frame.size.height*0.5)
                var size2 = CGSize(width: firstNumberLabel.frame.size.height, height: firstNumberLabel.frame.size.height)
                
                if node1 == subtractSprite{
                    size1.height *= 15/100
                }else if node3 == subtractSprite{
                    size2.height *= 15/100
                }
                
                node1.run(SKAction.resize(toWidth: size1.width, height: size1.height, duration: 0.25))
                node3.run(SKAction.resize(toWidth: size2.width, height: size2.height, duration: 0.25))
                
                node4.position = CGPoint(x: self.frame.size.width/6*5, y: self.frame.size.height/2)
                node4.run(SKAction.move(to: operationPos.object(at: 2) as! CGPoint, duration: 0.25))
                node4.run(SKAction.fadeIn(withDuration: 0.25))
                if operationInt == 4 {
                    operationInt = 1
                }else{
                    operationInt! += 1
                }
            }else{
                node1.run(SKAction.move(to: operationPos.object(at: 2) as! CGPoint, duration: 0.25))
                node2.run(SKAction.fadeOut(withDuration: 0.25))
                node2.run(SKAction.moveTo(x: self.frame.size.width/6*5, duration: 0.25))
                node3.run(SKAction.move(to: operationPos.object(at: 1) as! CGPoint, duration: 0.25))
                
                var size1 = CGSize(width: firstNumberLabel.frame.size.height*0.5, height: firstNumberLabel.frame.size.height*0.5)
                var size2 = CGSize(width: firstNumberLabel.frame.size.height, height: firstNumberLabel.frame.size.height)
                
                if node1 == subtractSprite{
                    size1.height *= 15/100
                }else if node3 == subtractSprite{
                    size2.height *= 15/100
                }
                
                node1.run(SKAction.resize(toWidth: size1.width, height: size1.height, duration: 0.25))
                node3.run(SKAction.resize(toWidth: size2.width, height: size2.height, duration: 0.25))
                
                node4.position = CGPoint(x: self.frame.size.width/6, y: self.frame.size.height/2)
                node4.run(SKAction.move(to: operationPos.object(at: 0) as! CGPoint, duration: 0.25))
                node4.run(SKAction.fadeIn(withDuration: 0.25))
                if operationInt == 1 {
                    operationInt = 4
                }else{
                    operationInt! -= 1
                }
            }
        }
    }
    
    func getNumberPosArray() -> NSMutableArray {
        var array = NSMutableArray()
        switch numberHidden {
        case 0:
            array = labelPos
        case 1:
            array = labelPos2
        case 2:
            array.add(labelPos.object(at: 1) as! CGPoint)
            array.add(labelPos.object(at: 2) as! CGPoint)
        default:
            break
        }
        return array
    }
    
    func getLabelPosArray() -> NSMutableArray {
        var array = NSMutableArray()
        if numberHidden == 0 {
            array = labelPos2
        }else if numberHidden == 1 {
            array.add(labelPos.object(at: 1) as! CGPoint)
            array.add(labelPos.object(at: 2) as! CGPoint)
        }else if numberHidden == 2 {
            array.add(labelPos2.object(at: 1) as! CGPoint)
        }else if numberHidden == -1 {
            array = labelPos
        }
        return array
    }
    
    func switchNumbers(right: Bool) {
        if !switchingNumbers {
            switchingNumbers = true
            let node = self.children[moveNodeIndex] as! SKNode
            var index = 0
            var modifier = 0
            if right{
                modifier = 1
            }else if !right{
                modifier = -1
            }
            switch node.position {
            case labelPos.object(at: 0) as! CGPoint:
                index = 0+modifier
            case labelPos.object(at: 1) as! CGPoint:
                index = 1+modifier
            case labelPos.object(at: 2) as! CGPoint:
                index = 2+modifier
            case labelPos.object(at: 3) as! CGPoint:
                index = 3+modifier
            default:
                break
            }
            if index < 4 && index >= 0{
                var node2:SKNode = SKNode()
                checkLoop: for var i in 1..<5{
                    if moveNodeIndex != i{
                        if self.children[i].position == labelPos.object(at: index) as! CGPoint{
                            node2 = self.children[i]
                            break checkLoop
                        }
                    }
                }
                let pos = node.position
                node.run(SKAction.move(to: labelPos.object(at: index) as! CGPoint, duration: 0.5))
                node2.run(SKAction.move(to: pos, duration: 0.5))

            }
            delay(0.5){
                self.switchingNumbers = false
            }
        }
    }
    
    func undo(lastOperatedNode: SKNode) {
        inUndoProcess = true
        var hiddenNode = SKNode()
        var number = 0
        var operation = 0
        let lastOperatedNodeIndex = self.children.index(of: lastOperatedNode)
        var hiddenIndex = lastOperated.index(of: lastOperatedNodeIndex as Any)
        for var i in 0..<2{
            if lastOperated.indexOfObjectIdentical(to: lastOperatedNodeIndex as Any) == 1 ||
                lastOperated.indexOfObjectIdentical(to: lastOperatedNodeIndex as Any) == 2 ||
                lastOperated.indexOfObjectIdentical(to: lastOperatedNodeIndex as Any) == 3 ||
                lastOperated.indexOfObjectIdentical(to: lastOperatedNodeIndex as Any) == 4 {
                    
                hiddenIndex = self.lastOperated.indexOfObjectIdentical(to: lastOperatedNodeIndex as Any)
            }
        }
        switch hiddenArray.object(at: hiddenIndex) as! Int{
        case 1:
            hiddenNode = firstNumberNode
            number = Int(firstNumberLabel.text!)!
            operation = operation1
            operation1 = 0
        case 2:
            hiddenNode = secondNumberNode
            number = Int(secondNumberLabel.text!)!
            operation = operation2
            operation2 = 0
        case 3:
            hiddenNode = thirdNumberNode
            number = Int(thirdNumberLabel.text!)!
            operation = operation3
            operation3 = 0
        case 4:
            hiddenNode = fourthNumberNode
            number = Int(fourthNumberLabel.text!)!
            operation = operation4
            operation4 = 0
        default: break
        }
        
        drawingLine = true
        line1.removeAllAnimations()
        line1.removeFromSuperlayer()
        line2.removeAllAnimations()
        line2.removeFromSuperlayer()
        numberHidden! -= 2
        var hideCounter = 0
        hideNumbers: for var i in 1..<5{
            if lastOperated[lastOperated.count-1] as! Int != i{
                self.children[i].run(SKAction.fadeOut(withDuration: 0.3))
                hideCounter += 1
                if hideCounter == 3{
                    break hideNumbers
                }
            }
        }
        delay(0.3){
            lastOperatedNode.run(SKAction.move(to: CGPoint(x: 0, y: -self.frame.size.height/4), duration: 0.3))
            self.shakeNode(node: lastOperatedNode, repeatTimes: 3)
            self.delay(0.7){
                lastOperatedNode.run(SKAction.fadeOut(withDuration: 0.3))
                self.delay(0.3){
                    let lastOperatedLabel = lastOperatedNode.children[0] as! SKLabelNode
                    switch operation {
                    case 1:
                        lastOperatedLabel.text = "\(Int(lastOperatedLabel.text!)!-number)"
                    case 2:
                        lastOperatedLabel.text = "\(Int(lastOperatedLabel.text!)!+number)"
                    case 3:
                        lastOperatedLabel.text = "\(Int(lastOperatedLabel.text!)!/number)"
                    case 4:
                        lastOperatedLabel.text = "\(Int(lastOperatedLabel.text!)!*number)"
                    default:
                        lastOperatedLabel.text = "\(Int(lastOperatedLabel.text!)!-number)"
                    }
                    lastOperatedNode.position = self.labelPos.object(at: 2) as! CGPoint
                    lastOperatedNode.run(SKAction.fadeIn(withDuration: 0.3))
                    hiddenNode.position = self.labelPos.object(at: 1) as! CGPoint
                    hiddenNode.run(SKAction.fadeIn(withDuration: 0.3))
                    self.delay(0.7){
                        let labelPosArray = self.getLabelPosArray()
                        lastOperatedNode.run(SKAction.move(to: labelPosArray.object(at: labelPosArray.count-1) as! CGPoint, duration: 0.3))
                        hiddenNode.run(SKAction.move(to: labelPosArray.object(at: labelPosArray.count-2) as! CGPoint, duration: 0.3))
                        self.delay(0.3){
                            var revealCounter = 0
                            revealHiddenNumbers: for var i in 1..<5{
                                if self.lastOperated[self.lastOperated.count-1] as! Int != i && self.hiddenArray[self.hiddenArray.count-1] as! Int != i && !self.hiddenArray.contains(self.children[i]){
                                    self.children[i].position = labelPosArray.object(at: revealCounter) as! CGPoint
                                    self.children[i].run(SKAction.fadeIn(withDuration: 0.3))
                                    revealCounter += 1
                                    if revealCounter+2 == labelPosArray.count{
                                        break revealHiddenNumbers
                                    }
                                }
                            }
                            self.delay(0.3){
                                self.hiddenArray.remove(self.hiddenArray[self.hiddenArray.count-1])
                                self.lastOperated.remove(self.lastOperated[self.lastOperated.count-1])
                                self.numberHidden! += 1
                                self.inUndoProcess = false
                                if self.stillTouching == false{
                                    self.drawingLine = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func shakeNode(node: SKNode, repeatTimes: Int) {
        for var i in 0..<repeatTimes{
            delay(0.3){
                node.run(SKAction.moveBy(x: 5, y: 0, duration: 0.05))
                self.delay(0.05){
                    node.run(SKAction.moveBy(x: -10, y: 0, duration: 0.1))
                    self.delay(0.1){
                        node.run(SKAction.moveBy(x: 5, y: 0, duration: 0.05))
                    }
                }
            }
        }
    }
    func printFonts() {
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
    
}
