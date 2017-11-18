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
    
    let settings = LineFormatSettings.sharedInstance
    let disposeBag = DisposeBag()
    
    lazy var lineImage : Variable<UIImage> = Variable<UIImage>(makeClearImage())
    
    // TODO: Change once screen size is dynamic
    let tempCanvasSize = UIScreen.main.bounds.size
    
    override init() {
        super.init()
        setupSubscriptions()
    }
    
    
    
    func makeClearImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0.0)
        UIColor.clear.setFill()
        UIRectFill(UIScreen.main.bounds)
        guard let lineImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Clear Image the size of the screen not created")
        }
        UIGraphicsEndImageContext()
        return lineImage
    }
    
    // MARK: - Creating Elements
    
    func newLine(_ lineToAdd: Line) {
        let newLineElement = LineElement(line: lineToAdd, width: settings.width, cap: settings.cap, color: settings.color)
       
       
       // TODO: have this sent by sequence? 
       // Maybe add class method to instruction manager that starts it subscribing to a new sequence
        InstructionManager.sharedInstance.addLine(newLineElement)
    }
    
    func newEmoji(_ : String) {
        
    }
    
    
    
    
    
    // MARK: - Displaying Elements
    
    
    func setupSubscriptions() {
        
        let _ /* New Lines Subscription */ = ElementModel.sharedInstance.lineSubject
            .subscribe { event in
                switch event{
                case .next(let newLines):
                    self.drawLines(newLines)
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed:
                    print("BoardViewModel Lines Subscription ended")
                }
        }
    }
 
    func drawLines(_ linesToDraw: [LineElement]) {
        self.lineImage.value = drawLineOnImage(existingImage: self.lineImage.value, lines: linesToDraw)
    }
    
    func drawLineOnImage(existingImage: UIImage, lines: [LineElement]) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(existingImage.size, false, 0.0)
        existingImage.draw(at: CGPoint(x: 0, y: 0))
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
