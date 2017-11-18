//
//  BoardViewController.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit
import RxSwift

class BoardViewController: UIViewController {

    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var lineImageView: UIImageView!
    
    let viewModel = BoardViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.clearsContextBeforeDrawing = true
        drawView.viewModel = self.viewModel
        
        self.viewModel.lineImage.asObservable()
            .subscribe(onNext: { lineImage in
                self.lineImageView.image = lineImage
            })
            .disposed(by: disposeBag)
    }
}

class LineFormatSettings {
    static let sharedInstance = LineFormatSettings()
    
    var width : CGFloat = 5.0
    var cap = CGLineCap.round
    var color = UIColor.blue
}



