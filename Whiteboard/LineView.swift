//
//  LineView.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-16.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit

class LineView: UIView {
    
    let lines : [LineElement]
    
    init(lines: [LineElement], size: CGSize) {
        self.lines = lines
        super.init(frame: CGRect(origin: CGPoint.zero, size: size))
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.lines = []
        super.init(coder: aDecoder)
    }
    
    
    func getImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    
    override func draw(_ rect: CGRect) {
        for currentLine in lines {
            self.drawOneLine(currentLine)
        }

    }
    
    private func drawOneLine(_ lineToDraw: LineElement) {
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
    
    

}
