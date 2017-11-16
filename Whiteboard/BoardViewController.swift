//
//  BoardViewController.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {

    @IBOutlet weak var boardView: DrawView!
    
    let viewModel = BoardViewModel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardView.lineDelegate = viewModel
        
        
        
        
        
    }

}

class LineFormatSettings {
    static let sharedInstance = LineFormatSettings()
    
    var width : CGFloat = 5.0
    var cap = CGLineCap.round
    var color = UIColor.blue
}



