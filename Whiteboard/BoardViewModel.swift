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
    
    
    // Displaying
    /*
    func compositeImage(image1: UIImage, image2: UIImage) -> UIImage {
        
        let bounds1 = CGRect(x: 0, y: 0, width: image1.size.width, height: image1.size.height)
        let bounds2 = CGRect(x: 0, y: 0, width: image2.size.width, height: image2.size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        if let cgImage1 = image1.cgImage {
            
            guard let ctx = CGContext(data: nil,
                                      width: cgImage1.width,
                                      height: cgImage1.height,
                                      bitsPerComponent: cgImage1.bitsPerComponent,
                                      bytesPerRow: cgImage1.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue)
                else {fatalError("CGContext failed")}
            ctx.scaleBy(x: UIScreen.main.scale, y: UIScreen.main.scale)
            ctx.draw(cgImage1, in: bounds1)
            ctx.setBlendMode(.normal)
            if let cgImage2 = image2.cgImage {
                ctx.draw(cgImage2, in: bounds2)
            }
            
            guard let returnImage = ctx.makeImage() else {fatalError("make image failed")}
            return UIImage(cgImage: returnImage)
            
        }
        return image1
    }
    */
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
