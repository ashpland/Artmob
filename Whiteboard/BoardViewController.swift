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
    @IBAction func linecolor(_ sender: Any) {
        MenubuttonHeightConstraint.constant = 248
        colorMenu.isHidden = false
    }
    @IBAction func line(_ sender: Any) {
        MenubuttonHeightConstraint.constant = 168
        lineMenu.isHidden = false
    }
    @IBAction func color(_ sender: UIButton) {
        var lineFormat = LineFormatSettings.sharedInstance
        switch sender.tag{
        case 0:
            lineFormat.color = UIColor.black
        case 1:
            lineFormat.color = UIColor.white
        case 2:
            lineFormat.color = UIColor.red
        case 3:
            lineFormat.color = UIColor.orange
        default:
            lineFormat.color = UIColor.brown
        }
    }
    @IBOutlet weak var colorMenu: UIView!
    @IBOutlet weak var lineMenu: UIView!
    @IBOutlet weak var mainMenu: UIView!
    @IBOutlet weak var MenubuttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var lineImageView: UIImageView!
    
    let viewModel = BoardViewModel()
    let disposeBag = DisposeBag()
    var mpcHandler = MPCHandler.sharedInstance
    
    @IBAction func Menu(_ sender: UIButton) {
        if mainMenu.isHidden {
            mainMenu.isHidden = false
            MenubuttonHeightConstraint.constant = 88
        } else{
            mainMenu.isHidden = true
            lineMenu.isHidden = true
            colorMenu.isHidden = true
            MenubuttonHeightConstraint.constant = 8
        }
        
    }
    @IBAction func Add(_ sender: Any) {
        if mpcHandler.session != nil{
            mpcHandler.setupBrowser()
            mpcHandler.browser.delegate = self
            self.present(mpcHandler.browser, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMenu.isHidden = true
        lineMenu.isHidden = true
        colorMenu.isHidden = true
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



