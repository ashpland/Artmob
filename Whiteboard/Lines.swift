//
//  Lines.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import UIKit

struct Line {
    var segments = [LineSegment]()
    mutating func addSegment(_ newSegment: LineSegment){
       self.segments.append(newSegment)
    }
}

struct LineSegment {
    let firstPoint : CGPoint
    let secondPoint : CGPoint
}


class LineFormatSettings {
    static let sharedInstance = LineFormatSettings()
    
    var width : CGFloat = 5.0
    var cap = CGLineCap.round
    var color = UIColor.blue
}

