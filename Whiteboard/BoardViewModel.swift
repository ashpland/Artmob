//
//  BoardViewModel.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit
import RxSwift

class BoardViewModel {
    
    fileprivate let settings = LineFormatSettings.sharedInstance
    fileprivate let disposeBag = DisposeBag()
        
    let submitInstruction = PublishSubject<Instruction>()
    
    internal lazy var lineImage : Variable<UIImage> = Variable<UIImage>(makeClearImage())
    
    // TODO: Change once screen size is dynamic
    fileprivate let tempCanvasSize = UIScreen.main.bounds.size
    
    init(){
        setupDisplaySubscriptions()
        setupInstructionBroadcast()
    }
    
    fileprivate func makeClearImage() -> UIImage {
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
    
    internal func recieveLine(_ subject: Observable<LineSegment>) {
        let _ = subject.reduce(Line(), accumulator: {
            currentLine, nextSegment in
            return currentLine + nextSegment
        }).subscribe(onNext: { line in
            let newInstruction = self.makeInstruction(for: line)
            self.submitInstruction.onNext(newInstruction)
        })
    }
    
    fileprivate func makeInstruction(for line: Line) -> Instruction {
        let newLineElement = LineElement(line: line, width: settings.width, cap: settings.cap, color: settings.color)
        let newInstruction = self.buildInstruction(type: .new, from: .line(newLineElement))
        return newInstruction
    }
    
    fileprivate func newEmoji(_ : String) {
        
    }
    
    fileprivate func buildInstruction(type: InstructionType, from payload: InstructionPayload) -> Instruction {
        let stamp = Stamp(user: UIDevice.current.name, timestamp: Date())
        return Instruction(type: type, element: payload, stamp: stamp)
    }
    
    fileprivate func setupInstructionBroadcast() {
        InstructionManager.subscribeToInstructionsFrom(self.submitInstruction)
    }
   
    
    // MARK: - Displaying Elements
    
    fileprivate func setupDisplaySubscriptions() {
    
        let _ /* New Lines Subscription */ = ElementModel.sharedInstance.lineSubject
            .subscribe { event in
                switch event{
                case .next(let newLines):
                    self.drawLines(newLines)
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed:
                    print("Line Subscription Completed")
                }
        }.disposed(by: disposeBag)
    }
    
    
 
    fileprivate func drawLines(_ linesToDraw: [LineElement]) {
        if linesToDraw.count > 1 {
            self.lineImage.value = self.makeClearImage()
        }
        self.lineImage.value = drawLineOnImage(existingImage: self.lineImage.value, lines: linesToDraw)
    }
    
    fileprivate func drawLineOnImage(existingImage: UIImage, lines: [LineElement]) -> UIImage{
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
