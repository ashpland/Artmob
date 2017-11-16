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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lineDelegate.newLine(activeDrawingLine)
        activeDrawingLine = Line()
    }
}



protocol lineMakingDelegate {
    func newLine(_: Line)
}
