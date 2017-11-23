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

    @IBOutlet weak var MainMenuButton: UIButton!
    @IBOutlet weak var MainMenuHeight: NSLayoutConstraint!
    @IBAction func thickness(_ sender: UIButton) {
        let formatLine = LineFormatSettings.sharedInstance
        switch sender.tag{
        case 0:
            formatLine.width = 3.0
            break
        case 1:
            formatLine.width = 5.0
            break
        default:
            formatLine.width = 8.0
            break
        }
    }
    @IBAction func color(_ sender: UIButton) {
        print(sender.tag)
        let formatLine = LineFormatSettings.sharedInstance
        switch sender.tag{
        case 0:
            formatLine.color = LineColor.black
        case 1:
            formatLine.color = LineColor.white
        case 2:
            formatLine.color = LineColor.red
        case 3:
            formatLine.color = LineColor.orange
        case 4:
            formatLine.color = LineColor.yellow
        case 5:
            formatLine.color = LineColor.green
        case 6:
            formatLine.color = LineColor.blue
        case 7:
            formatLine.color = LineColor.purple
        default:
            formatLine.color = LineColor.black
        }
    }

    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var lineImageView: UIImageView!
    
    let viewModel = BoardViewModel()
    let disposeBag = DisposeBag()
    var mpcHandler = MPCHandler.sharedInstance
    
    @IBAction func addLabel(_ sender: Any) {
        //AddLabel
    }
    @IBAction func Menu(_ sender: UIButton) {
        
        if MainMenuHeight.constant == -148{
            UIView.animate(withDuration: 0.5, animations: {
                self.MainMenuHeight.constant = 0
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.view.layoutIfNeeded()
            })
        } else{
            UIView.animate(withDuration: 0.5, animations: {
                self.MainMenuHeight.constant = -148
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: 0)
                self.view.layoutIfNeeded()
            })
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
        MainMenuHeight.constant = -148
        mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        mpcHandler.setupSession()
        mpcHandler.advertiseSelf(advertise: true)
        mpcHandler.setupSubscribe()
        
        
        
        
        drawView.clearsContextBeforeDrawing = true
        drawView.viewModel = self.viewModel
        
        self.viewModel.lineImage.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { lineImage in
                UIView.transition(with: self.view,
                                  duration: 0.25,
                                  options: UIViewAnimationOptions.transitionCrossDissolve,
                                  animations: { self.lineImageView.image = lineImage },
                                  completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

class LineFormatSettings {
    static let sharedInstance = LineFormatSettings()
    
    var width : CGFloat = 5.0
    var cap = CGLineCap.round
    var color = LineColor.blue
}



