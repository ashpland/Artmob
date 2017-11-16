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
    let lineImageView : UIImageView
    
    init(lines: [LineElement], lineImage: UIImage) {
        self.lines = lines
        self.lineImageView = UIImageView(image: lineImage)
        super.init(frame: CGRect(origin: CGPoint.zero, size: lineImage.size))
        
        self.addSubview(self.lineImageView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.lines = []
        self.lineImageView = UIImageView()
        super.init(coder: aDecoder)
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
