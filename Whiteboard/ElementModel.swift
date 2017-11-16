//
//  ElementModel.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-16.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import UIKit

class ElementModel {
    
    static let sharedInstance = ElementModel()
    
    var lines = [LineElement]()
    
    var labels = [Stamp : LabelElement]()
    
    
    
}



struct LineElement {
    let line : Line
    let width : CGFloat
    let cap : CGLineCap
    let color : UIColor
}

struct LabelElement {
    let stamp : Stamp
    
}
