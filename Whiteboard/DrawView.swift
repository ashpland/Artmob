//
//  BoardView.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit
import RxSwift

protocol CloseMenu {
    func closeMenu()
}
class DrawView: UIView {
    var closeMenuDelagate:CloseMenu?
    private var activeDrawingLine = Line()
    private let lineFormatSettings = LineFormatSettings.sharedInstance
    public var lineStream = PublishSubject<Line>()
    public var viewModel : BoardViewModel!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Began")
        closeMenuDelagate?.closeMenu()
        self.activeDrawingLine = Line()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Moved")

        let touch = touches.first
        if let first = touch?.previousLocation(in: self),
            let second = touch?.location(in: self) {
            let lineSegment = LineSegment(firstPoint: first, secondPoint: second)
            self.activeDrawingLine = self.activeDrawingLine + lineSegment
        }
        self.setNeedsDisplay()
        //setNeedsDisplayInRect
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lineStream.onNext(self.activeDrawingLine)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Ended")
        self.lineStream.onNext(self.activeDrawingLine)
        print("Ended Ended")
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

