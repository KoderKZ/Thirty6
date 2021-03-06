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
        labelPos.add(CGPoint(x: -self.frame.size.width/4, y: self.frame.size.height/4))
        labelPos.add(CGPoint(x: self.frame.size.width/4, y: self.frame.size.height/4))
        labelPos.add(CGPoint(x: -self.frame.size.width/4, y: -self.frame.size.height/4))
        labelPos.add(CGPoint(x: self.frame.size.width/4, y: -self.frame.size.height/4))
        
        labelPos2.add(CGPoint(x: 0, y: self.frame.size.height/4))
        labelPos2.add(CGPoint(x: self.frame.size.width/4, y: 0))
        labelPos2.add(CGPoint(x: 0, y: -self.frame.size.height/4))
        labelPos2.add(CGPoint(x: -self.frame.size.width/4, y: 0))
    }
    
    func operationSwitch() {
        let operationLabel:SKLabelNode
        
        switch moveNodeIndex {
        case 1:
            operationLabel = firstNumberNode.children[1] as! SKLabelNode
            if operation1 == 4{
                operation1 = 0
            }else{
                operation1! += 1
            }
            animateOperation(node: operationLabel, operation: operation1)
        case 2:
            operationLabel = secondNumberNode.children[1] as! SKLabelNode
            if operation2 == 4{
                operation2 = 0
            }else{
                operation2! += 1
            }
            animateOperation(node: operationLabel, operation: operation2)
        case 3:
            operationLabel = thirdNumberNode.children[1] as! SKLabelNode
            if operation3 == 4{
                operation3 = 0
            }else{
                operation3! += 1
            }
            animateOperation(node: operationLabel, operation: operation3)
        case 4:
            operationLabel = fourthNumberNode.children[1] as! SKLabelNode
            if operation4 == 4{
                operation4 = 0
            }else{
                operation4! += 1
            }
            animateOperation(node: operationLabel, operation: operation4)
        default:
            break
        }

        for var i in 1..<5{
            if i != moveNodeIndex{
                var node:SKNode = SKNode()
                switch i {
                case 1:
                    node = firstNumberNode
                    if node.alpha != 0{
                        operation1 = 0
                    }
                case 2:3
                    node = secondNumberNode
                    if node.alpha != 0{
                        operation2 = 0
                    }
                case 3:
                    node = thirdNumberNode
                    if node.alpha != 0{
                        operation3 = 0
                    }
                case 4:
                    node = fourthNumberNode
                    if node.alpha != 0{
                        operation4 = 0
                    }
                default:
                    break
                }
                if node.alpha != 0{
                    let nodeOperation = node.children[1] as! SKLabelNode
                    animateOperation(node: nodeOperation, operation: 0)
                }
            }
        }
    }
    
    func animateOperation(node:SKLabelNode, operation:Int) {
        let operationArray = NSMutableArray(objects: "", "+", "-", "*", "/")

        let moveMargin1 = firstNumberLabel.frame.size.height
        node.run(SKAction.moveBy(x: 0, y: -moveMargin1, duration: 0.1))
        node.run(SKAction.fadeOut(withDuration: 0.1))
        delay(0.2){
            node.text = operationArray[operation] as? String
            node.position.y = node.position.y+moveMargin1*2
            node.run(SKAction.fadeIn(withDuration: 0.1))
            node.run(SKAction.moveBy(x: 0, y: -moveMargin1, duration: 0.1))
        }
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
        
        errorOverlay.addChild(errorOverlayScreen)
        errorOverlay.addChild(undoMessage)
        errorOverlay.addChild(endMessage)
    }
    
    func createNumLabel(num: Int) -> SKNode {

//        let operationMargin:CGFloat = 10
        
        let numLabelNode = SKNode()
        
        let numLabel = SKLabelNode(text: "\(numberArray[num])")
        numLabel.fontSize = 50
        numLabel.fontName = "TimeBurner-Bold"
        numLabel.fontColor = .black
        numLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        numLabel.horizontalAlignmentMode = .center
        numLabel.verticalAlignmentMode = .center
        numLabelNode.addChild(numLabel)
        
        let numLabelMargin = (numLabel.frame.size.height)/2
        let numAddMargin = (numLabel.frame.size.height)/2
        
        let numOperator = SKLabelNode(text: "")
        numOperator.fontName = "TimeBurner-Bold"
        numOperator.fontSize = 50
        numOperator.fontColor = .black
        numOperator.position = CGPoint(x: self.frame.size.width/2-numLabelMargin-numAddMargin-10, y: self.frame.size.height/2)
        numOperator.horizontalAlignmentMode = .center
        numOperator.verticalAlignmentMode = .center
        numLabelNode.addChild(numOperator)
        numOperator.alpha = 1

        
        
        //CGPoint(x: self.frame.size.width/2-numLabelMargin-numAddMargin-10, y: self.frame.size.height/2)
//        let numAdd = SKLabelNode(text: "+")
//        numAdd.fontSize = 40
//        numAdd.fontColor = .black
//        numAdd.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2+numLabel.frame.size.height/2+numAdd.frame.size.height/2+operationMargin)
//        numAdd.horizontalAlignmentMode = .center
//        numAdd.verticalAlignmentMode = .center
//        numLabelNode.addChild(numAdd)
//        numAdd.alpha = 0
//        
//        let numSubtract = SKLabelNode(text: "-")
//        numSubtract.fontSize = 40
//        numSubtract.fontColor = .black
//        numSubtract.position = CGPoint(x: self.frame.size.width/2-numLabel.frame.size.height/2-numAdd.frame.size.height/2-operationMargin, y: self.frame.size.height/2)
//        numSubtract.horizontalAlignmentMode = .center
//        numSubtract.verticalAlignmentMode = .center
//        numLabelNode.addChild(numSubtract)
//        numSubtract.alpha = 0
//        
//        let numMultiply = SKLabelNode(text: "*")
//        numMultiply.fontSize = 40
//        numMultiply.fontColor = .black
//        numMultiply.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2-numLabel.frame.size.height/2-numAdd.frame.size.height/2-operationMargin)
//        numMultiply.horizontalAlignmentMode = .center
//        numMultiply.verticalAlignmentMode = .center
//        numLabelNode.addChild(numMultiply)
//        numMultiply.alpha = 0
//        
//        let numDivide = SKLabelNode(text: "/")
//        numDivide.fontSize = 40
//        numDivide.fontColor = .black
//        numDivide.position = CGPoint(x: self.frame.size.width/2+numLabel.frame.size.height/2+numAdd.frame.size.height/2+operationMargin, y: self.frame.size.height/2)
//        numDivide.horizontalAlignmentMode = .center
//        numDivide.verticalAlignmentMode = .center
//        numLabelNode.addChild(numDivide)
//        numDivide.alpha = 0
        
        
        return numLabelNode
    }
    
    func setUpLabels(){
        ThirtysixLabel = SKLabelNode(text: "36")
        ThirtysixLabel.fontSize = 75
        ThirtysixLabel.fontName = "TimeBurner-Bold"
        ThirtysixLabel.fontColor = .black
        ThirtysixLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
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
        
        backButton = SKSpriteNode(imageNamed: "backButton.png")
        backButton.size = CGSize(width: 10, height: 25)
        backButton.color = .black
        backButton.position = CGPoint(x: backButton.size.width*3, y: self.frame.size.height-(backButton.size.height*2.5))
        addChild(backButton)
        
        undoButton = SKSpriteNode(imageNamed: "undoButton.png")
        undoButton.size = CGSize(width: 50, height: 42.5)
        undoButton.color = .black
        undoButton.position = CGPoint(x: undoButton.size.width*1.5, y: undoButton.size.height*1.5)
        addChild(undoButton)
        
    }
    
    func undo() {
        var hiddenNode = SKNode()
        var number = 0
        var operation = 0
        switch hiddenArray.object(at: hiddenArray.count-1) as! Int{
        case 1:
            firstNumberNode.alpha = 1
            hiddenNode = firstNumberNode
            number = Int(firstNumberLabel.text!)!
            operation = operation1
            operation1 = 0
        case 2:
            secondNumberNode.alpha = 1
            hiddenNode = secondNumberNode
            number = Int(secondNumberLabel.text!)!
            operation = operation2
            operation2 = 0
        case 3:
            thirdNumberNode.alpha = 1
            hiddenNode = thirdNumberNode
            number = Int(thirdNumberLabel.text!)!
            operation = operation3
            operation3 = 0
        case 4:
            fourthNumberNode.alpha = 1
            hiddenNode = fourthNumberNode
            number = Int(fourthNumberLabel.text!)!
            operation = operation4
            operation4 = 0
        default: break
        }
        var lastOperatedLabel:SKLabelNode!
        switch lastOperated[lastOperated.count-1] as! Int{
        case 1:
            lastOperatedLabel = firstNumberLabel
        case 2:
            lastOperatedLabel = secondNumberLabel
        case 3:
            lastOperatedLabel = thirdNumberLabel
        case 4:
            lastOperatedLabel = fourthNumberLabel
        default:
            
            lastOperatedLabel = firstNumberLabel
        }
        lastOperated.remove(lastOperated[lastOperated.count-1])
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
        hiddenArray.remove(hiddenArray[hiddenArray.count-1])
        numberHidden! -= 1
        hiddenNode.children[1].alpha = 0
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
