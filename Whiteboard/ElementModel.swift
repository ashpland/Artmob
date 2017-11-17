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
    
    // TODO: remove this later probably
    public var viewModel : BoardViewModel?
    
    private var lines = [LineElement]()
    
    private var labels = [Stamp : LabelElement]()
    
    public func recieveInstruction(_ instruction: Instruction) {
        switch instruction.element {
        case .line (let newLine):
            self.addLine(newLine)
        case .emoji:
            processLabel(instruction)
        }
    }
    private func addLine(_ newLine: LineElement) {
    self.lines.append(newLine)
    // TODO: remove drawLines call and have LineElements sent by sequence
    self.viewModel?.drawLines([newLine])
    }
    
    private func processLabel(_ labelInstruction: Instruction) {
        
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
