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
    
    
    let submitInstruction = PublishSubject<InstructionAndHashBundle>()
    
    internal lazy var lineImage : Variable<UIImage> = Variable<UIImage>(makeClearImage())
    
    // TODO: Change once screen size is dynamic
    fileprivate let tempCanvasSize = UIScreen.main.bounds.size
    
    init(){
        setupDisplaySubscriptions()
        setupInstructionBroadcast()
    }
    
    fileprivate func makeClearImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 2000, height: 2000), false, 0.0)
        UIColor.clear.setFill()
        UIRectFill(UIScreen.main.bounds)
        guard let lineImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Clear Image the size of the screen not created")
        }
        UIGraphicsEndImageContext()
        return lineImage
    }
    
    // MARK: - Creating Elements
    
    internal func recieveLine(_ subject: Observable<Line>) {
        print("Recieve Start")
        
        let _ = subject.subscribe(onNext: { (line) in
            let newInstructionBundle = InstructionAndHashBundle(instruction: self.makeInstruction(for: line), hash: nil)
            self.submitInstruction.onNext(newInstructionBundle)
            print("Line Receieved")
        }, onCompleted: {
            print("Recieve Complete\n")
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
        let stamp = Stamp(user: MPCHandler.sharedInstance.session.myPeerID, timestamp: Date())
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
    
    func clear(){
        self.lineImage.value = self.makeClearImage()
    }
    
    fileprivate func drawLines(_ linesToDraw: [LineElement]) {
        
        var newImage: UIImage
        
        if linesToDraw.count > 1 {
            newImage = self.makeClearImage()
        } else {
            newImage = self.lineImage.value
        }
        newImage = self.drawLineOnImage(existingImage: newImage, lines: linesToDraw)
        self.lineImage.value = newImage
    }
    
    
    fileprivate func drawLineOnImage(existingImage: UIImage, lines: [LineElement]) -> UIImage{
        let newImageCALayer = CALayer()
        newImageCALayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: existingImage.size)
        
        let existingImageLayer = CALayer()
        existingImageLayer.contents = existingImage.cgImage
        
        newImageCALayer.addSublayer(existingImageLayer)
        
        for lineToDraw in lines {
            newImageCALayer.addSublayer(self.drawLine(lineToDraw))
        }
        
        UIGraphicsBeginImageContextWithOptions(existingImage.size, false, 0.0)
        
        newImageCALayer.render(in: UIGraphicsGetCurrentContext()!)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Line was not able to be drawn on image")
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawLine(_ lineElement: LineElement) -> CALayer {
        guard !lineElement.line.segments.isEmpty else {
            return CALayer()
        }
        
        let shapeLayer = CAShapeLayer()
        
        let linePath = UIBezierPath()
        
        linePath.move(to: lineElement.line.segments.first!.firstPoint)
        
        for segment in lineElement.line.segments {
            linePath.addLine(to: segment.secondPoint)
        }
        
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = lineElement.color.uiColor.cgColor
        shapeLayer.lineWidth = lineElement.width
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.fillColor = nil
        
        return shapeLayer
    }
}
