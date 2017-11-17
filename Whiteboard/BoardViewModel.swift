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
    
    
    // TODO: have this triggered by sequence subscription
    func drawLines(_ linesToDraw: [LineElement]) {
        //let newLines = LineView(lines: linesToDraw, size: tempCanvasSize).getImage()
        if lineImage == nil {
            UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0.0)
            UIColor.clear.setFill()
            UIRectFill(UIScreen.main.bounds)
            lineImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        lineImage = LineView.getImage(img: lineImage!, lines: linesToDraw)

//        if lineImage == nil{
//            lineImage = newLines
//        } else if newLines != nil{
//            lineImage = compositeImage(image1: lineImage!, image2: newLines)
//        }
        bvc?.image = lineImage

        //
//        UIGraphicsBeginImageContext(tempCanvasSize)
//        //if let oldLines = self.lineImage?.value {
//        if let oldLines = self.lineImage {
//            oldLines.draw(at: CGPoint.zero)
//        }
//        newLines?.draw(at: CGPoint.zero)
//        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
//            //self.lineImage?.value = newImage
//            self.lineImage = newImage
//
//        }
//        UIGraphicsEndImageContext()
    }
    

}
