//
//  BoardView.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit
import RxSwift

class DrawView: UIView {

    private var activeDrawingLine = Line()
    private let lineFormatSettings = LineFormatSettings.sharedInstance
    public var lineStream : PublishSubject<LineSegment>!
    public var viewModel : BoardViewModel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lineStream = PublishSubject<LineSegment>()
        self.viewModel.recieveLine(self.lineStream)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let first = touch?.previousLocation(in: self),
            let second = touch?.location(in: self) {
            let lineSegment = LineSegment(firstPoint: first, secondPoint: second)
            self.activeDrawingLine = self.activeDrawingLine + lineSegment
            self.lineStream.onNext(lineSegment)
        }
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lineStream.onCompleted()
        activeDrawingLine = Line()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        let drawMe = LineElement(line: activeDrawingLine, width: lineFormatSettings.width, cap: lineFormatSettings.cap, color: lineFormatSettings.color)
        path.lineWidth = drawMe.width
        path.lineCapStyle = drawMe.cap
        drawMe.drawColor.setStroke()
        
        if !drawMe.line.segments.isEmpty {
            
            path.move(to: drawMe.line.segments.first!.firstPoint)
            
            for segment in drawMe.line.segments {
                path.addLine(to: segment.firstPoint)
                path.addLine(to: segment.secondPoint)
            }
            path.stroke()
        }
    }
}

