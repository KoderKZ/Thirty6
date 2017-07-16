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
        firstNumberLabel.fontColor = labelColor
        secondNumberLabel.text = "\(numberArray[1])"
        secondNumberLabel.fontColor = labelColor
        thirdNumberLabel.text = "\(numberArray[2])"
        thirdNumberLabel.fontColor = labelColor
        fourthNumberLabel.text = "\(numberArray[3])"
        fourthNumberLabel.fontColor = labelColor
        
        for var i in 8..<12{
            let circle = self.children[i].children[0] as! SKShapeNode
            circle.fillColor = viewBackgroundColor
        }
        
        operation1 = 0
        operation2 = 0
        operation3 = 0
        operation4 = 0
        operationInt = 1
        
        for var i in 8..<12{
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
    
    func calculatePoint(radius:CGFloat, point:CGPoint, numberPos: CGPoint) -> CGPoint{
        var returnPoint = CGPoint()
        
        var modifier:CGFloat = 0
        
        if point.y == firstNumberNode.position.y {
            modifier = -1
        }else{
            modifier = 1
        }

        
        let operationPoint = operationPos.object(at: 1) as! CGPoint
        let updatedNumberPos = CGPoint(x: numberPos.x+self.frame.size.width/2, y: numberPos.y+self.frame.size.height)
        let aSquared = (operationPoint.x-updatedNumberPos.x) * (operationPoint.x-updatedNumberPos.x)
        let bSquared = (operationPoint.y-updatedNumberPos.y) * (operationPoint.y-updatedNumberPos.y)
        let c = sqrt(aSquared+bSquared)
        let expression = (operationPoint.x-updatedNumberPos.x)*radius/c
        let x = point.x-(modifier*expression)
        let y = point.y+(modifier*((operationPoint.y-updatedNumberPos.y)*radius/c))
        
        returnPoint = CGPoint(x: x, y: y)
        
        if point == numberPos{
            returnPoint.y += self.frame.size.height/2
            returnPoint.x += self.frame.size.width/2
        }
        
        return returnPoint
    }
    
    func createNumLabel(num: Int) -> SKNode {

        
        let numLabelNode = SKNode()
        
        let numLabel = SKLabelNode(text: "\(numberArray[num])")
        numLabel.fontSize = 50
        numLabel.fontName = "TimeBurner-Bold"
        numLabel.fontColor = labelColor
        numLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        numLabel.horizontalAlignmentMode = .center
        numLabel.verticalAlignmentMode = .center
        
        numberRadius = numLabel.frame.size.height*4/5
        
        let circlePath = UIBezierPath.init(arcCenter: numLabelNode.position, radius: numberRadius, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: false)
        
        let numCircle = SKShapeNode()
        numCircle.path = circlePath.cgPath
        numCircle.fillColor = self.backgroundColor
        numCircle.lineWidth = 3
        numCircle.strokeColor = labelColor
        numCircle.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        
        numLabelNode.addChild(numCircle)
        numLabelNode.addChild(numLabel)
        
        return numLabelNode
    }
    
    
    func setUpLabels(){
        ThirtysixLabel = SKLabelNode(text: "36")
        ThirtysixLabel.fontSize = 75
        ThirtysixLabel.fontName = "TimeBurner-Bold"
        ThirtysixLabel.fontColor = labelColor
        ThirtysixLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/4*3)
        ThirtysixLabel.horizontalAlignmentMode = .center
        ThirtysixLabel.verticalAlignmentMode = .center
        addChild(ThirtysixLabel)
        
        firstNumberNode = createNumLabel(num: 0)
        firstNumberNode.position = labelPos.object(at: 0) as! CGPoint
        
        secondNumberNode = createNumLabel(num: 1)
        secondNumberNode.position = labelPos.object(at: 1) as! CGPoint
        
        thirdNumberNode = createNumLabel(num: 2)
        thirdNumberNode.position = labelPos.object(at: 2) as! CGPoint
        
        fourthNumberNode = createNumLabel(num: 3)
        fourthNumberNode.position = labelPos.object(at: 3) as! CGPoint
        
        firstNumberLabel = firstNumberNode.children[1] as! SKLabelNode
        secondNumberLabel = secondNumberNode.children[1] as! SKLabelNode
        thirdNumberLabel = thirdNumberNode.children[1] as! SKLabelNode
        fourthNumberLabel = fourthNumberNode.children[1] as! SKLabelNode
        
        let width1 = firstNumberLabel.frame.size.height*0.5
        let width2 = firstNumberLabel.frame.size.height
        
        addSprite = SKSpriteNode(imageNamed: "add.png")
        addSprite.position = operationPos.object(at: 1) as! CGPoint
        addSprite.color = labelColor
        addSprite.colorBlendFactor = 1
        addSprite.size = CGSize(width: width2, height: width2)
        
        subtractSprite = SKSpriteNode(imageNamed: "subtract.png")
        subtractSprite.position = operationPos.object(at: 2) as! CGPoint
        subtractSprite.color = labelColor
        subtractSprite.colorBlendFactor = 1
        subtractSprite.size = CGSize(width: width1, height: width1/100*15)
        
        multiplySprite = SKSpriteNode(imageNamed: "multiply.png")
        multiplySprite.color = labelColor
        multiplySprite.colorBlendFactor = 1
        multiplySprite.size = CGSize(width: width1, height: width1)
        multiplySprite.alpha = 0
        
        divideSprite = SKSpriteNode(imageNamed: "divide.png")
        divideSprite.position = operationPos.object(at: 0) as! CGPoint
        divideSprite.color = labelColor
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
        circle.strokeColor = labelColor
        circle.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        addChild(circle)
        
        line1 = SKShapeNode()
        line2 = SKShapeNode()
        line1.alpha = 0
        line2.alpha = 0
        
        addChild(line1)
        addChild(line2)
        
        addChild(firstNumberNode)
        addChild(secondNumberNode)
        addChild(thirdNumberNode)
        addChild(fourthNumberNode)
        
        backButton = SKSpriteNode(imageNamed: "backButton.png")
        backButton.size = CGSize(width: 10, height: 25)
        backButton.color = labelColor
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
            for var i in 0..<3{
                array.add(labelPos2.object(at: i) as! CGPoint)
            }
        }else if numberHidden == 1 {
            array.add(labelPos.object(at: 1) as! CGPoint)
            array.add(labelPos.object(at: 2) as! CGPoint)
        }else if numberHidden == 2 {
            array.add(labelPos2.object(at: 1) as! CGPoint)
        }else if numberHidden == -1 {
            for var i in 0..<4{
                array.add(labelPos.object(at: i) as! CGPoint)
            }
        }
        return array
    }
    
    func switchNumbers(right: Bool) {
        if !switchingNumbers && moveNodeIndex != 0{
            switchingNumbers = true
            line1.alpha = 0
            line2.alpha = 0
            let node = self.children[moveNodeIndex] 
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
                checkLoop: for var i in 8..<12{
                    if moveNodeIndex != i{
                        if self.children[i].position == labelPos.object(at: index) as! CGPoint{
                            node2 = self.children[i]
                            break checkLoop
                        }
                    }
                }
                let pos = node.position
                
                node.run(SKAction.fadeOut(withDuration: 0.2))
                node2.run(SKAction.fadeOut(withDuration: 0.2))
                
                delay(0.2){
                    node.position = self.labelPos.object(at: index) as! CGPoint
                    node2.position = pos
                    node.run(SKAction.fadeIn(withDuration: 0.2))
                    node2.run(SKAction.fadeIn(withDuration: 0.2))
                }

            }
        }
    }
    
    func undo(lastOperatedNode: SKNode) {
        inUndoProcess = true
        var hiddenNode = SKNode()
        var number = 0
        var operation = 0
        var lastOperatedNodeIndex = self.children.index(of: lastOperatedNode)!
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
        
        var hiddenNodeIndex = self.children.index(of: hiddenNode)
        
        drawingLine = true
        line1.alpha = 0
        line2.alpha = 0
        var hideCounter = 0
        delay(0.3){
            let lastOperatedLabel = lastOperatedNode.children[1] as! SKLabelNode
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
            
            self.numberHidden! -= 1
            let originalLabelPosArray = self.getLabelPosArray()
            
            var node1PosIndex = 0
            
            for var i in 0..<originalLabelPosArray.count{
                if lastOperatedNode.position == originalLabelPosArray.object(at: i) as! CGPoint{
                    node1PosIndex = i
                }
            }
            
            hiddenNode.position = lastOperatedNode.position
            if lastOperatedNodeIndex > hiddenNodeIndex!{
                hiddenNode.removeFromParent()
                self.insertChild(hiddenNode, at: lastOperatedNodeIndex)
            }
            hiddenNodeIndex = lastOperatedNodeIndex
            lastOperatedNodeIndex += 1
            
            self.numberHidden! -= 1
            let labelPosArray = self.getLabelPosArray()
            
            hiddenNode.run(SKAction.fadeIn(withDuration: 0.05))
            hiddenNode.run(SKAction.move(to: labelPosArray.object(at: node1PosIndex+1) as! CGPoint, duration: 0.1))
            self.hiddenArray.remove(self.hiddenArray.object(at: hiddenIndex))
            self.lastOperated.remove(self.lastOperated.object(at: hiddenIndex))
            
            if !self.lastOperated.contains(lastOperatedNodeIndex){
                let nodeCircle = lastOperatedNode.children[0] as! SKShapeNode
                
                lastOperatedLabel.fontColor = self.labelColor
                nodeCircle.fillColor = self.viewBackgroundColor
            }            
            lastOperatedNode.run(SKAction.move(to: labelPosArray.object(at: node1PosIndex) as! CGPoint, duration: 0.1))

            labelPosArray.remove(labelPosArray.object(at: node1PosIndex))
            labelPosArray.remove(labelPosArray.object(at: node1PosIndex))
            var moveCounter = 0
            moveNodes: for var i in 8..<12{
                if self.children[i] != lastOperatedNode && self.children[i] != hiddenNode && !self.hiddenArray.contains(self.children[i]){
                    self.children[i].run(SKAction.move(to: labelPosArray.object(at: moveCounter) as! CGPoint, duration: 0.1))
                    moveCounter += 1
                    if moveCounter == labelPosArray.count{
                        break moveNodes
                    }
                }
            }
            self.delay(0.2){
                self.numberHidden! += 1
                self.inUndoProcess = false
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
