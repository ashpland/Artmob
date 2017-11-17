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
    lazy var lineImage : UIImage = {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0.0)
        UIColor.clear.setFill()
        UIRectFill(UIScreen.main.bounds)
        guard let lineImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Clear Image the size of the screen not created")
        }
        UIGraphicsEndImageContext()
        return lineImage
    }()
    
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
    
    // TODO: have this triggered by sequence subscription
    func drawLines(_ linesToDraw: [LineElement]) {
        lineImage = drawLineOnImage(img: lineImage, lines: linesToDraw)
        bvc?.image = lineImage
    }
    
    func drawLineOnImage(img: UIImage, lines: [LineElement]) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(img.size, false, 0.0)
        img.draw(at: CGPoint(x: 0, y: 0))
        for lineToDraw in lines {
            let path = UIBezierPath()
            path.lineWidth = lineToDraw.width
            path.lineCapStyle = lineToDraw.cap
            lineToDraw.color.setStroke()
            
            if !lineToDraw.line.segments.isEmpty {
                path.move(to: lineToDraw.line.segments.first!.firstPoint)
                
                for segment in lineToDraw.line.segments {
                    path.addLine(to: segment.firstPoint)
                    path.addLine(to: segment.secondPoint)
                }
                path.stroke()
            }
        }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Line was not able to be drawn on image")
        }
        UIGraphicsEndImageContext()
        return image
    }
}
