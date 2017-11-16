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
    
    var currentLineSubject : PublishSubject<LineSegment>!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentLineSubject = PublishSubject<LineSegment>()
        self.lineDelegate.startNewLine(source: currentLineSubject)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        if let first = touch?.previousLocation(in: self),
            let second = touch?.location(in: self) {
            currentLineSubject.onNext(LineSegment(firstPoint: first, secondPoint: second))
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentLineSubject.onCompleted()
    }
    

}



protocol lineMakingDelegate {
    func startNewLine(source: PublishSubject<LineSegment>)
}
