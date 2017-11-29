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
    private lazy var shapeLayer = setupShapeLayer()
    
    
    func setupShapeLayer() -> CAShapeLayer {
        let newShapeLayer = CAShapeLayer()
        newShapeLayer.frame = self.bounds
        
        self.layer.addSublayer(newShapeLayer)
  
        return newShapeLayer
    }
    
    func updateLine() {
        let linePath = UIBezierPath()
       
        if !activeDrawingLine.segments.isEmpty {
            linePath.move(to: activeDrawingLine.segments.first!.firstPoint)
            
            for segment in activeDrawingLine.segments {
                linePath.addLine(to: segment.secondPoint)
            }
        }
        
        
        
        self.shapeLayer.path = linePath.cgPath
        self.shapeLayer.strokeColor = lineFormatSettings.color.uiColor.cgColor
        self.shapeLayer.lineWidth = lineFormatSettings.width
        self.shapeLayer.lineJoin = kCALineJoinRound
        self.shapeLayer.lineCap = kCALineCapRound
        self.shapeLayer.fillColor = nil
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeMenuDelagate?.closeMenu()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let first = touch?.previousLocation(in: self),
            let second = touch?.location(in: self) {
            let lineSegment = LineSegment(firstPoint: first, secondPoint: second)
            self.activeDrawingLine = self.activeDrawingLine + lineSegment
        }
        
        self.updateLine()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeDrawingLine = Line()
        self.updateLine()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lineStream.onNext(self.activeDrawingLine)
        self.activeDrawingLine = Line()
        self.updateLine()
    }
}

