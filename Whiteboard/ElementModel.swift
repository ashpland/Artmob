//
//  ElementModel.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-16.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import UIKit

class ElementModel {
    
    static let sharedInstance = ElementModel()
    
    var lines = [LineElement]()
    
    var labels = [Stamp : LabelElement]()
    
    func recieveInstruction(_ instruction: Instruction) {
        switch instruction.element {
        case .line (let newLine):
            self.addLine(newLine)
        case .emoji:
            processLabel(instruction)
        }
    }
    func addLine(_ newLine: LineElement) {
        self.lines.append(newLine)
    }
    
    func processLabel(_ labelInstruction: Instruction) {
        
    }
    
        
        
    
}



struct LineElement {
    let line : Line
    let width : CGFloat
    let cap : CGLineCap
    let color : UIColor
}

struct LabelElement {
    let stamp : Stamp
    
}
