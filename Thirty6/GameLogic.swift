//
//  GameLogic.swift
//  Thirty6
//
//  Created by Kevin Zhou on 6/19/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import SpriteKit

class GameLogic {

    func calculateNumbers() -> NSMutableArray{
        
        let numberArray = NSMutableArray(capacity: 4)
        var calculateNumber = 0
        
        for var i in 0..<3{
            let randomOpNumber = arc4random_uniform(4)
            var randCalculateNum:Int = 0
            switch randomOpNumber {
            case 0:
                randCalculateNum = Int(arc4random_uniform(15))
                calculateNumber += randCalculateNum
                numberArray.insert(randCalculateNum, at: i)
            case 1:
                randCalculateNum = Int(arc4random_uniform(15))
                calculateNumber -= randCalculateNum
                numberArray.insert(randCalculateNum, at: i)
            case 2:
                randCalculateNum = Int(arc4random_uniform(3))+1
                calculateNumber *= randCalculateNum
                numberArray.insert(randCalculateNum, at: i)
            case 3:
                randCalculateNum = Int(arc4random_uniform(10))
                calculateNumber /= randCalculateNum
                numberArray.insert(randCalculateNum, at: i)
            default:
                calculateNumber += 0
            }
            
        }
        
        let lastNum = 36-calculateNumber
        numberArray.insert(lastNum, at: 3)
        return numberArray
    }
    
    func calculateNumbers2() -> NSMutableArray{
        let numberArray = NSMutableArray(capacity: 4)
        var calculateNumber = 36
        var randCalculateNum = Int(arc4random_uniform(10))+5
        numberArray.insert(randCalculateNum, at: 0)
        calculateNumber -= randCalculateNum
        for var i in 0..<2{
            randCalculateNum = 0
            if calculateNumber<36/(i+2){
                if Int(arc4random_uniform(2)) == 1{
                    randCalculateNum = Int(arc4random_uniform(10))+5
                    calculateNumber += randCalculateNum
                    numberArray.add(randCalculateNum)
                }else{
                    randCalculateNum = Int(arc4random_uniform(1))+1
                    calculateNumber *= randCalculateNum
                    numberArray.add(randCalculateNum)
                }
            }else{
                if Int(arc4random_uniform(2)) == 1{
                    divisionCheck: for var j in 2..<calculateNumber{
                        if calculateNumber%j == 0{
                            calculateNumber /= j
                            numberArray.add(j)
                            break divisionCheck
                        }
                    }
                    if randCalculateNum == 0{
                        randCalculateNum = Int(arc4random_uniform(5))+1
                        calculateNumber *= randCalculateNum
                        numberArray.add(randCalculateNum)
                    }
                }else{
                    randCalculateNum = Int(arc4random_uniform(5))+1
                    calculateNumber *= randCalculateNum
                    numberArray.add(randCalculateNum)
                }
            }
        }
        let lastNum = abs(36-calculateNumber)
        numberArray.add(lastNum)
        return numberArray
    }
    
    func checkIfNodeInTouch(node: SKNode, touch: CGPoint, multiplier: CGFloat) -> Bool {
        if touch.x < node.position.x+node.frame.size.width*multiplier &&
            touch.x > node.position.x-node.frame.size.width*multiplier &&
            touch.y < node.position.y+node.frame.size.height*multiplier &&
            touch.y > node.position.y-node.frame.size.height*multiplier {
            
            return true
        }else{
            return false
        }
    }
    
    func operateNumbers(num1: Int, num2: Int, operation: Int) -> Int {
        switch operation {
        case 1:
            return num1+num2
        case 2:
            if num1-num2 < 0{
                return -1
            }else{
                return num1-num2
            }
        case 3:
            return num1*num2
        case 4:
            if num1%num2 != 0{
                return -1
            }else{
                return num1/num2
            }
        default:
            return 0
        }
    }
    
}
