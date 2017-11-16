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
    var lineImage : Variable<UIImage>?
    
    let tempCanvasSize = UIScreen.main.bounds.size
    
    override init() {
        super.init()
        ElementModel.sharedInstance.viewModel = self
    }
    
    // Creating
    
    func newLine(_ lineToAdd: Line) {
        let newLineElement = LineElement(line: lineToAdd, width: settings.width, cap: settings.cap, color: settings.color)
        instructionManager.addLine(newLineElement)
    }
    
    func newEmoji(_ : String) {
        
    }
    
    
    // Displaying
    
    func drawLines(_ linesToDraw: [LineElement]) {
        let newLines = LineView(lines: linesToDraw, size: tempCanvasSize).getImage()
        
        UIGraphicsBeginImageContext(tempCanvasSize)
        if let oldLines = self.lineImage?.value {
            oldLines.draw(at: CGPoint.zero)
        }
        newLines?.draw(at: CGPoint.zero)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Can't get UIImage from LineView")
        }
        self.lineImage?.value = newImage
        UIGraphicsEndImageContext()
    }
    

}
