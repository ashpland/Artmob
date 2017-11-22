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
        var formatLine = LineFormatSettings.sharedInstance
        switch sender.tag{
        case 0:
            formatLine.width = 0.3
            break
        case 1:
            formatLine.width = 0.5
            break
        default:
            formatLine.width = 1
            break
        }
    }
    @IBAction func color(_ sender: UIButton) {
        var formatLine = LineFormatSettings.sharedInstance
        switch sender.tag{
        case 0:
            formatLine.color = UIColor.black
        case 1:
            formatLine.color = UIColor.red
        case 2:
            formatLine.color = UIColor.orange
        case 3:
            formatLine.color = UIColor.yellow
        case 4:
            formatLine.color = UIColor.green
        case 5:
            formatLine.color = UIColor.blue
        case 6:
            formatLine.color = UIColor.purple
        case 7:
            formatLine.color = UIColor.white
        default:
            formatLine.color = UIColor.black
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
        /*
         
         UIView.animate(withDuration: 1.25, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: [], animations: {
         // Values for end state of animation
         self.plusButton.transform = CGAffineTransform(rotationAngle: 0)
         self.snackLabelYConstraint.constant = 0
         self.snackLabel.text = "SNACKS"
         self.navHeightConstraint.constant = 64
         self.view.layoutIfNeeded()
         }) { (finished: Bool) in
         // Completion and cleanup
         }
         
         */
        if MainMenuHeight.constant == -148{
            UIView.animate(withDuration: 1.25, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: [], animations: {
                self.MainMenuHeight.constant = 0
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: 270)
                self.view.layoutIfNeeded()
            }) { (finished: Bool) in
                // Completion and cleanup
            }
            
        } else{
            UIView.animate(withDuration: 1.25, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: [], animations: {
                self.MainMenuHeight.constant = -148
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: 0)
                self.view.layoutIfNeeded()
            }) { (finished: Bool) in
                // Completion and cleanup
            }
            
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
    var color = UIColor.blue
}



