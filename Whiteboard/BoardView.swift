//
//  BoardView.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit
import RxSwift

class BoardView: UIView {

    var lineDelegate : lineMakingDelegate!
    
    var currentLineSubject : PublishSubject<LineSegment>!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        currentLineSubject = PublishSubject<LineSegment>()
        
        
        
        let touch = touches.first
        
        
        // start new line
        // make first points
        // add to line
        // display
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    

}



protocol lineMakingDelegate {
    func startNewLine()
}
