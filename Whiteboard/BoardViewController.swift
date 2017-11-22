//
//  BoardViewController.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit
import RxSwift
import MultipeerConnectivity

class BoardViewController: UIViewController, MCBrowserViewControllerDelegate  {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var lineImageView: UIImageView!
    
    let viewModel = BoardViewModel()
    let disposeBag = DisposeBag()
    var mpcHandler = MPCHandler.sharedInstance
    
    
    @IBAction func Add(_ sender: Any) {
        if mpcHandler.session != nil{
            mpcHandler.setupBrowser()
            mpcHandler.browser.delegate = self
            self.present(mpcHandler.browser, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        mpcHandler.setupSession()
        mpcHandler.advertiseSelf(advertise: true)
        mpcHandler.setupSubscribe()
        
        
        
        drawView.clearsContextBeforeDrawing = true
        drawView.viewModel = self.viewModel
        
        self.viewModel.lineImage.asObservable()
            .subscribe(onNext: { lineImage in
                DispatchQueue.main.async {
                    self.lineImageView.image = lineImage
                }
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



