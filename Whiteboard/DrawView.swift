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

    var lineDelegate : lineMakingDelegate!
    var activeDrawingLine = Line()
    
 
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let first = touch?.previousLocation(in: self),
            let second = touch?.location(in: self) {
            let nextLineSegment = LineSegment(firstPoint: first, secondPoint: second)
            activeDrawingLine.addSegment(nextLineSegment)
        }
        
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lineDelegate.newLine(activeDrawingLine)
        activeDrawingLine = Line()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = 5.0
        path.lineCapStyle = CGLineCap.round
        UIColor.blue.setStroke()
        
        if !activeDrawingLine.segments.isEmpty {
            path.move(to: activeDrawingLine.segments.first!.firstPoint)
            
            for segment in activeDrawingLine.segments {
                path.addLine(to: segment.firstPoint)
                path.addLine(to: segment.secondPoint)
            }
            path.stroke()
        }
        
        
        
        
    }
    
    
}



protocol lineMakingDelegate {
    func newLine(_: Line)
}
