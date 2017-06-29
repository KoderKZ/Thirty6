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
        
        hiddenArray = NSMutableArray(capacity: 4)
        setUpLabelPosArray()
        
        setUpLabels()
        
        
        moveNodeIndex = 0
        moveOperationIndex = 0
        moveNumberBool = false
        moveOperationBool = false
        
        
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
        }else if gameLogic.checkIfNodeInTouch(node: subtractSprite, touch: touch!){
            moveOperationIndex = 2
        }else if gameLogic.checkIfNodeInTouch(node: multiplySprite, touch: touch!){
            moveOperationIndex = 3
        }else if gameLogic.checkIfNodeInTouch(node: divideSprite, touch: touch!){
            moveOperationIndex = 4
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
        
//        operationTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { operationTimer in
//        })
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
            addSprite.position = touch!
            moveOperationBool = true
        case 2:
            subtractSprite.position = touch!
            moveOperationBool = true
        case 3:
            multiplySprite.position = touch!
            moveOperationBool = true
        case 4:
            divideSprite.position = touch!
            moveOperationBool = true
        default:
            moveOperationBool = false
            if moveNodeIndex != 0{
                switchNumbers()
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
        
        if moveOperationBool {
            switch moveOperationIndex {
            case 1:
                addSprite.position = operationPos.object(at: 0) as! CGPoint
            case 2:
                subtractSprite.position = operationPos.object(at: 1) as! CGPoint
            case 3:
                multiplySprite.position = operationPos.object(at: 2) as! CGPoint
            case 4:
                divideSprite.position = operationPos.object(at: 3) as! CGPoint
            default:
                break
            }
            moveOperationBool = false
        } else if moveNumberBool {

            
            if moveNodeIndex != 0 {
                touch?.x -= self.frame.size.width/2
                touch?.y -= self.frame.size.height/2
                var textNode:SKLabelNode = SKLabelNode()
                var operation:Int = 0
                mathLoop: for var i in 1..<5{
                    
                    let checkNode = self.children[i]
                    if checkNode.children.count != 0{
                        var checkNodeText = checkNode.children[0] as! SKLabelNode
                        let checkNodePos = checkNode.position
                        let checkNodeSize = CGSize(width: 50, height: 50)
                        let checkNodeNumber = Int(checkNodeText.text!)
                        var number:Int = 0
                        if (touch?.x)! > checkNodePos.x-checkNodeSize.width &&
                            (touch?.x)! < checkNodePos.x+checkNodeSize.width &&
                            (touch?.y)! > checkNodePos.y-checkNodeSize.height*2 &&
                            (touch?.y)! < checkNodePos.y+checkNodeSize.height*2{
                            
                            if moveNodeIndex != i {
                                switch moveNodeIndex {
                                case 1:
                                    textNode = firstNumberNode.children[0] as! SKLabelNode
                                    firstNumberNode.position = checkNodePos
                                    checkNode.run(SKAction.move(to: beginNumberPos, duration: 0.5))
                                    break mathLoop
                                case 2:
                                    textNode = secondNumberNode.children[0] as! SKLabelNode
                                    secondNumberNode.position = checkNodePos
                                    checkNode.run(SKAction.move(to: beginNumberPos, duration: 0.5))
                                    break mathLoop
                                case 3:
                                    textNode = thirdNumberNode.children[0] as! SKLabelNode
                                    thirdNumberNode.position = checkNodePos
                                    checkNode.run(SKAction.move(to: beginNumberPos, duration: 0.5))
                                    break mathLoop
                                case 4:
                                    textNode = fourthNumberNode.children[0] as! SKLabelNode
                                    fourthNumberNode.position = checkNodePos
                                    checkNode.run(SKAction.move(to: beginNumberPos, duration: 0.5))
                                    break mathLoop
                                default:
                                    moveNodeIndex = 0
                                }
                            }else{
                                switch moveNodeIndex {
                                case 1:
                                    firstNumberNode.position = beginNumberPos
                                case 2:
                                    secondNumberNode.position = beginNumberPos
                                case 3:
                                    thirdNumberNode.position = beginNumberPos
                                case 4:
                                    fourthNumberNode.position = beginNumberPos
                                default:
                                    break
                                }
                            }
                        }
                    }
                }
            }
            beginNumberPos = CGPoint(x: 0, y: 0)
            moveNumberBool = false
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
//        if moveBool{
//            switch moveNodeIndex {
//            case 1:
//                firstNumberNode.position = labelPos.object(at: 0) as! CGPoint
//            case 2:
//                secondNumberNode.position = labelPos.object(at: 1) as! CGPoint
//            case 3:
//                thirdNumberNode.position = labelPos.object(at: 2) as! CGPoint
//            case 4:
//                fourthNumberNode.position = labelPos.object(at: 3) as! CGPoint
//            default:
//                break
//            }
//
//            touch?.x -= self.frame.size.width/2
//            touch?.y -= self.frame.size.height/2
//            var textNode:SKLabelNode = SKLabelNode()
//            var operation:Int = 0
//            mathLoop: for var i in 1..<5{
//                if moveNodeIndex != i{
//                    let checkNode = self.children[i]
//                    if checkNode.children.count != 0{
//                        var checkNodeText = checkNode.children[0] as! SKLabelNode
//                        let checkNodePos = checkNode.position
//                        let checkNodeSize = CGSize(width: 50, height: 50)
//                        let checkNodeNumber = Int(checkNodeText.text!)
//                        var number:Int = 0
//                        if (touch?.x)! > checkNodePos.x-checkNodeSize.width &&
//                            (touch?.x)! < checkNodePos.x+checkNodeSize.width &&
//                            (touch?.y)! > checkNodePos.y-checkNodeSize.height*2 &&
//                            (touch?.y)! < checkNodePos.y+checkNodeSize.height*2{
//                            switch moveNodeIndex {
//                            case 1:
//                                textNode = firstNumberNode.children[0] as! SKLabelNode
//                                firstNumberNode.position = labelPos.object(at: 0) as! CGPoint
//                                if textNode != checkNodeText && checkNode.alpha != 0 && operation1 != 0{
//                                    number = Int(textNode.text!)!
//                                    operation = operation1
////                                        operation1 = 0
//                                    hiddenArray.add(1)
//                                }else{
//                                    break mathLoop
//                                }
//                            case 2:
//                                textNode = secondNumberNode.children[0] as! SKLabelNode
//                                secondNumberNode.position = labelPos.object(at: 1) as! CGPoint
//                                if textNode != checkNodeText && checkNode.alpha != 0 && operation2 != 0{
//                                    number = Int(textNode.text!)!
//                                    operation = operation2
////                                        operation2 = 0
//                                    hiddenArray.add(2)
//                                }else{
//                                    break mathLoop
//                                }
//                            case 3:
//                                textNode = thirdNumberNode.children[0] as! SKLabelNode
//                                thirdNumberNode.position = labelPos.object(at: 2) as! CGPoint
//                                if textNode != checkNodeText && checkNode.alpha != 0 && operation3 != 0{
//                                    number = Int(textNode.text!)!
//                                    operation = operation3
////                                        operation3 = 0
//                                    hiddenArray.add(3)
//                                }else{
//                                    break mathLoop
//                                }
//                            case 4:
//                                textNode = fourthNumberNode.children[0] as! SKLabelNode
//                                fourthNumberNode.position = labelPos.object(at: 3) as! CGPoint
//                                if textNode != checkNodeText && checkNode.alpha != 0 && operation4 != 0{
//                                    number = Int(textNode.text!)!
//                                    operation = operation4
////                                        operation4 = 0
//                                    hiddenArray.add(4)
//                                }else{
//                                    break mathLoop
//                                }
//                                
//                            default:
//                                moveNodeIndex = 0
//                            }
//                            lastOperated.add(i)
//                            if textNode != checkNodeText && checkNode.alpha != 0 && operation != 0{
//                                if (operation == 2 && checkNodeNumber!-number < 0) || (operation == 4 && (number == 0 || checkNodeNumber!%number != 0)) {
////                                    switch moveNodeIndex {
////                                    case 1:
////                                        operation1 = operation
////                                    case 2:
////                                        operation2 = operation
////                                    case 3:
////                                        operation3 = operation
////                                    case 4:
////                                        operation4 = operation
////                                    default:
////                                        operation = 0
////                                    }
//                                    hiddenArray.remove(hiddenArray.count-1)
//                                    operation = 0
//                                    break mathLoop
//                                }else{
//                                    textNode.parent?.alpha = 0
//                                    (numberHidden)! += 1
//                                }
//                            }
//                            if operation != 0 && textNode != checkNodeText{
//                                checkNodeText.text = "\(gameLogic.operateNumbers(num1: number, num2: checkNodeNumber!, operation: operation))"
//                                break mathLoop
//
//                            }
////                            if numberHidden == 1{
////                                if (textNode == firstNumberLabel && checkNodeText == secondNumberLabel) || (textNode == secondNumberLabel && checkNodeText == firstNumberLabel) {
////                                    checkNode.run(SKAction.move(to: labelPos2[0] as! CGPoint, duration: 0.5))
////                                    orientHorizontal = false
////                                }else if (textNode == secondNumberLabel && checkNodeText == fourthNumberLabel) || (textNode == fourthNumberLabel && checkNodeText == secondNumberLabel) {
////                                    checkNode.run(SKAction.move(to: labelPos2[1] as! CGPoint, duration: 0.5))
////                                    orientHorizontal = true
////                                }else if (textNode == fourthNumberLabel && checkNodeText == thirdNumberLabel) || (textNode == thirdNumberLabel && checkNodeText == fourthNumberLabel) {
////                                    checkNode.run(SKAction.move(to: labelPos2[2] as! CGPoint, duration: 0.5))
////                                    orientHorizontal = false
////                                }else if (textNode == thirdNumberLabel && checkNodeText == firstNumberLabel) || (textNode == firstNumberLabel && checkNodeText == thirdNumberLabel) {
////                                    checkNode.run(SKAction.move(to: labelPos2[3] as! CGPoint, duration: 0.5))
////                                    orientHorizontal = true
////                                }
////                            }else if numberHidden == 2{
////                                let nodeArray = NSMutableArray(capacity: 2)
////                                for var i in 1..<4{
////                                    if self.children[i].alpha != 0 {
////                                        nodeArray.add(self.children[i])
////                                    }
////                                }
////                                if orientHorizontal{
////                                    for var i in 0..<1 {
////                                        let referenceNode = nodeArray[i] as! SKNode
////                                        nodeArray.remove(i)
////                                        let moveNode = nodeArray[0] as! SKNode
////                                        if referenceNode.position.y == 0 {
////                                            if referenceNode.position.x == -self.frame.size.width/4 {
////                                                moveNode.run(SKAction.move(to: labelPos2.object(at: 3) as! CGPoint, duration: 0.5))
////                                            }else if referenceNode.position.x == self.frame.size.width/4 {
////                                                moveNode.run(SKAction.move(to: labelPos2.object(at: 1) as! CGPoint, duration: 0.5))
////                                            }
////                                        }
////                                    }
////                                }else{
////                                    for var i in 0..<1 {
////                                        let referenceNode = nodeArray[i] as! SKNode
////                                        nodeArray.remove(i)
////                                        let moveNode = nodeArray[0] as! SKNode
////                                        if referenceNode.position.x == 0 {
////                                            if referenceNode.position.y == self.frame.size.height/4 {
////                                                moveNode.run(SKAction.move(to: labelPos2.object(at: 2) as! CGPoint, duration: 0.5))
////                                            }else if referenceNode.position.x == -self.frame.size.height/4 {
////                                                moveNode.run(SKAction.move(to: labelPos2.object(at: 0) as! CGPoint, duration: 0.5))
////                                            }
////                                        }
////                                    }
////                                }
////                            }
//                        }
//                    }
//                }
//                
//            }
//
////            switch moveNodeIndex {
////            case 1:
////                firstNumberNode.position = CGPoint(x: -self.frame.size.width/4, y: self.frame.size.height/4)
////            case 2:
////                secondNumberNode.position = CGPoint(x: self.frame.size.width/4, y: self.frame.size.height/4)
////            case 3:
////                thirdNumberNode.position = CGPoint(x: -self.frame.size.width/4, y: -self.frame.size.height/4)
////            case 4:
////                fourthNumberNode.position = CGPoint(x: self.frame.size.width/4, y: -self.frame.size.height/4)
////             default:
////                moveNodeIndex = 0
////            }
//            moveBool = false
//            moveNodeIndex = 0
//            if numberHidden == 3{
//                var hiddenAdded = 0
//                var node = SKNode()
//                for var i in 0..<3 {
//                    hiddenAdded += hiddenArray[i] as! Int
//                }
//                var finalNumber = 0
//                switch 10-hiddenAdded {
//                case 1:
//                    finalNumber = Int(firstNumberLabel.text!)!
//                    node = firstNumberNode
//                case 2:
//                    finalNumber = Int(secondNumberLabel.text!)!
//                    node = secondNumberNode
//                case 3:
//                    finalNumber = Int(thirdNumberLabel.text!)!
//                    node = thirdNumberNode
//                case 4:
//                    finalNumber = Int(fourthNumberLabel.text!)!
//                    node = fourthNumberNode
//                default:
//                    break
//                }
//                let label = node.children[0] as! SKLabelNode
//                if finalNumber == 36{
//                    delay(0.5){
//                        node.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.5))
//                        let wait1 = SKAction.wait(forDuration: 0.02)
//                        let block1 = SKAction.run({
//                            label.fontSize = label.fontSize+(1)
//                        })
//                        let sequence1 = SKAction.sequence([wait1, block1])
//                        label.run(SKAction.repeat(sequence1, count: 25))
//
//                        self.delay(0.6){
//                            node.run(SKAction.fadeOut(withDuration: 0.25))
//                            let wait2 = SKAction.wait(forDuration: 0.05)
//                            let block2 = SKAction.run({
//                                label.fontSize = label.fontSize+(25/36)
//                                self.ThirtysixLabel.text = "\(Int(self.ThirtysixLabel.text!)!-1)"
//                                
//                            })
//                            
//                            let sequence2 = SKAction.sequence([wait2, block2])
//                            
//                            self.ThirtysixLabel.run(SKAction.repeat(sequence2, count: 36))
//                            self.delay(2){
//                                node.alpha = 0
//                                let transition = SKTransition.flipVertical(withDuration: 0.5)
//                                let endScene = EndGame(size: self.size)
//                                self.view?.presentScene(endScene, transition: transition)
//                            }
//                        }
//                    }
//                }else{
//                    for var i in 0..<3{
//                        undo()
//                    }
//                    addChild(errorOverlay)
//                    errorOverlay.children[0].run(SKAction.fadeAlpha(to: 0.75, duration: 0.25))
//                    errorOverlay.children[2].run(SKAction.fadeIn(withDuration: 0.25))
//                    delay(1){
//                        self.errorOverlay.children[0].run(SKAction.fadeOut(withDuration: 0.25))
//                        self.errorOverlay.children[2].run(SKAction.fadeOut(withDuration: 0.25))
//                        self.delay(0.25){
//                            self.errorOverlay.removeFromParent()
//                        }
//                    }
//                }
//            }
//        }else{
//            //calculateNumbers2()
//            let touchedNode = self.atPoint(touch!)
//            //if touchedNode != nil{
//            
//            if gameLogic.checkIfNodeInTouch(node: backButton, touch: touch!){
//                let transition = SKTransition.flipVertical(withDuration: 0.5)
//                let titleScene = TitleScene(size: self.size)
//                self.view?.presentScene(titleScene, transition: transition)
//            }else if gameLogic.checkIfNodeInTouch(node: undoButton, touch: touch!){
//                if hiddenArray.count != 0{
//                    undo()
//                }else{
//                    if !self.children.contains(errorOverlay) {
//                        addChild(errorOverlay)
//                        errorOverlay.children[0].run(SKAction.fadeAlpha(to: 0.75, duration: 0.25))
//                        errorOverlay.children[1].run(SKAction.fadeIn(withDuration: 0.25))
//                        delay(1){
//                            self.errorOverlay.children[0].run(SKAction.fadeOut(withDuration: 0.25))
//                            self.errorOverlay.children[1].run(SKAction.fadeOut(withDuration: 0.25))
//                            self.delay(0.25){
//                                self.errorOverlay.removeFromParent()
//                            }
//                        }
//                    }
//                    
//                }
//            }
////            }else if touchedNode == self.children[1].children[0] || touchedNode == self.children[2].children[0] || touchedNode == self.children[3].children[0] || touchedNode == self.children[4].children[0]{
////                self.operationSwitch()
////            }
//
//        }
//
    }
    
}
