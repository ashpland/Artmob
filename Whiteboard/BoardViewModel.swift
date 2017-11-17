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
    //var lineImage : Variable<UIImage>?
    var lineImage : UIImage?
    var bvc : UIImageView?
    
    let tempCanvasSize = UIScreen.main.bounds.size
    
    override init() {
        super.init()
        ElementModel.sharedInstance.viewModel = self
        // TODO: initialize lineImage here with a transparent image
    }
    
    // Creating
    
    func newLine(_ lineToAdd: Line) {
        let newLineElement = LineElement(line: lineToAdd, width: settings.width, cap: settings.cap, color: settings.color)
       
       
       // TODO: have this sent by sequence? 
       // Maybe add class method to instruction manager that starts it subscribing to a new sequence
        instructionManager.addLine(newLineElement)
    }
    
    func newEmoji(_ : String) {
        
    }
    
    
    // Displaying
    
    
    // TODO: have this triggered by sequence subscription
    func drawLines(_ linesToDraw: [LineElement]) {
        let newLines = LineView(lines: linesToDraw, size: tempCanvasSize).getImage()
        
        UIGraphicsBeginImageContext(tempCanvasSize)
        //if let oldLines = self.lineImage?.value {
        if let oldLines = self.lineImage {
            oldLines.draw(at: CGPoint.zero)
        }
        newLines?.draw(at: CGPoint.zero)
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            //self.lineImage?.value = newImage
            self.lineImage = newImage
            
        }
        UIGraphicsEndImageContext()
        bvc?.image = self.lineImage
    }
    

}
