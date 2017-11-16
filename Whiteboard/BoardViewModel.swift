//
//  BoardViewModel.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit
import RxSwift

class BoardViewModel: NSObject, lineMakingDelegate {
    
    let instructionManager = InstructionManager.sharedInstance
    let settings = LineFormatSettings.sharedInstance
    var lineImage : UIImage?
    
    let tempCanvasSize = UIScreen.main.bounds.size
    
    override init() {
        super.init()
        ElementModel.sharedInstance.viewModel = self
    }
    
    func newLine(_ lineToAdd: Line) {
        let newLineElement = LineElement(line: lineToAdd, width: settings.width, cap: settings.cap, color: settings.color)
        instructionManager.addLine(newLineElement)
    }
    
    func newEmoji(_ : String) {
        
    }
    
    func drawLines(_ linesToDraw: [LineElement]) {
        let newLines = LineView(lines: linesToDraw, size: tempCanvasSize).getImage()
        
        UIGraphicsBeginImageContext(tempCanvasSize)
        if let oldLines = self.lineImage {
            oldLines.draw(at: CGPoint.zero)
        }
        newLines?.draw(at: CGPoint.zero)
        self.lineImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    

}
